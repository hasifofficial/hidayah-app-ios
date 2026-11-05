//
//  TestSupport.swift
//  simple-quranTests
//

import Foundation
import SwiftData
import UserNotifications
import XCTest
@testable import simple_quran

// MARK: - Store and preferences

@MainActor
func makeInMemoryStore() -> HidayahStore {
    HidayahStore(makeContainer: HidayahStore.makeInMemoryContainer)
}

/// Clears every key the app writes, so each test starts from defaults.
func resetStorage() {
    for key in Storage.StorageKey.allCases {
        Storage.delete(key)
    }
}

// MARK: - Clock

/// A settable clock for code that takes `now: () -> Date`.
final class TestClock {
    var now: Date

    init(_ now: Date) {
        self.now = now
    }

    /// Midday on the given day in the tracker calendar, so day keys are stable
    /// regardless of the simulator's time zone.
    static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return TrackerDayKey.calendar.date(from: components)!
    }

    func advance(days: Int) {
        now = TrackerDayKey.calendar.date(
            byAdding: .day,
            value: days,
            to: now
        )!
    }
}

// MARK: - Notifications

@MainActor
final class FakeNotificationCenter: NotificationScheduling {
    private(set) var scheduled: [UNNotificationRequest] = []
    private(set) var removed: [[String]] = []
    var pending: [String] = []

    func schedule(_ request: UNNotificationRequest) {
        scheduled.append(request)
        pending.append(request.identifier)
    }

    func removePending(identifiers: [String]) {
        removed.append(identifiers)
        pending.removeAll { identifiers.contains($0) }
    }

    func pendingIdentifiers() async -> [String] {
        pending
    }
}

// MARK: - Networking

/// Serves canned responses to an `APIClientService` built with `makeSession()`.
final class StubURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) throws -> (HTTPURLResponse, Data)

    nonisolated(unsafe) static var handler: Handler?
    nonisolated(unsafe) static var requests: [URLRequest] = []

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    static func reset() {
        handler = nil
        requests = []
    }

    static func respond(
        status: Int = 200,
        json: String
    ) {
        handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(json.utf8))
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requests.append(request)

        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

func makeStubbedSurahService() -> SurahService {
    SurahService(
        apiClientService: APIClientService(
            session: StubURLProtocol.makeSession()
        )
    )
}

// MARK: - Async helpers

extension XCTestCase {
    /// Waits until `condition` holds, letting main-actor tasks run in between.
    @MainActor
    func waitUntil(
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ condition: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline {
                XCTFail("Timed out waiting for condition", file: file, line: line)
                return
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}
