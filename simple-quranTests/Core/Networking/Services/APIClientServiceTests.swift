//
//  APIClientServiceTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class APIClientServiceTests: XCTestCase {
    private var sut: APIClientService!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        sut = APIClientService(session: StubURLProtocol.makeSession())
    }

    override func tearDown() {
        StubURLProtocol.reset()
        sut = nil
        super.tearDown()
    }

    func test_request_should_decodeSuccessfulResponse() async throws {
        // Arrange
        StubURLProtocol.respond(json: #"{"value":"ok"}"#)

        // Act
        let result = try await sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)

        // Assert
        XCTAssertEqual(result, CoreEcho(value: "ok"))
    }

    func test_request_should_buildURLFromEndpoint() async throws {
        // Arrange
        StubURLProtocol.respond(json: #"{"value":"ok"}"#)

        // Act
        _ = try await sut.request(
            endpoint: CoreTestEndpoint(path: "/v1/surah", method: .delete),
            type: CoreEcho.self
        )

        // Assert
        let request = try XCTUnwrap(StubURLProtocol.requests.first)
        XCTAssertEqual(request.url?.absoluteString, "https://api.alquran.cloud/v1/surah")
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertNil(request.sentBody)
    }

    func test_request_should_sendHeadersAndJSONBody() async throws {
        // Arrange
        StubURLProtocol.respond(json: #"{"value":"ok"}"#)
        let endpoint = CoreTestEndpoint(
            method: .post,
            header: ["Authorization": "Bearer test-token"],
            body: ["surah": "18"]
        )

        // Act
        _ = try await sut.request(endpoint: endpoint, type: CoreEcho.self)

        // Assert
        let request = try XCTUnwrap(StubURLProtocol.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        let body = try XCTUnwrap(request.sentBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: String]
        XCTAssertEqual(json, ["surah": "18"])
    }

    func test_request_should_acceptAny2xxStatus() async throws {
        // Arrange
        StubURLProtocol.respond(status: 201, json: #"{"value":"created"}"#)

        // Act
        let result = try await sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)

        // Assert
        XCTAssertEqual(result.value, "created")
    }

    func test_request_should_throwUnauthorizedFor401() async {
        // Arrange
        StubURLProtocol.respond(status: 401, json: "{}")

        // Act
        let error = await capturedError {
            try await self.sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)
        }

        // Assert
        XCTAssertEqual(error as? RequestError, .unauthorized)
    }

    func test_request_should_throwUnexpectedStatusCodeFor500() async {
        // Arrange
        StubURLProtocol.respond(status: 500, json: "{}")

        // Act
        let error = await capturedError {
            try await self.sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)
        }

        // Assert
        XCTAssertEqual(error as? RequestError, .unexpectedStatusCode)
    }

    func test_request_should_throwInvalidURLForRelativePath() async {
        // Arrange
        let endpoint = CoreTestEndpoint(path: "no-leading-slash")

        // Act
        let error = await capturedError {
            try await self.sut.request(endpoint: endpoint, type: CoreEcho.self)
        }

        // Assert
        XCTAssertEqual(error as? RequestError, .invalidURL)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func test_request_should_throwDecodingErrorForUnexpectedPayload() async {
        // Arrange
        StubURLProtocol.respond(json: #"{"other":1}"#)

        // Act
        let error = await capturedError {
            try await self.sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)
        }

        // Assert
        XCTAssertTrue(error is DecodingError)
    }

    func test_request_should_throwNoResponseForNonHTTPResponse() async {
        // Arrange
        let client = APIClientService(session: CoreNonHTTPURLProtocol.makeSession())

        // Act
        let error = await capturedError {
            try await client.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)
        }

        // Assert
        XCTAssertEqual(error as? RequestError, .noResponse)
    }

    func test_request_should_propagateTransportError() async {
        // Arrange
        StubURLProtocol.handler = nil

        // Act
        let error = await capturedError {
            try await self.sut.request(endpoint: CoreTestEndpoint(), type: CoreEcho.self)
        }

        // Assert
        XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
    }

    private func capturedError(
        _ operation: () async throws -> CoreEcho
    ) async -> Error? {
        do {
            _ = try await operation()
            return nil
        } catch {
            return error
        }
    }
}
