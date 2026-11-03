//
//  SurahServiceTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class SurahServiceTests: XCTestCase {
    private var sut: SurahService!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        sut = makeStubbedSurahService()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        sut = nil
        super.tearDown()
    }

    func test_getSurahEdition_should_requestEditionEndpoint() async throws {
        // Arrange
        StubURLProtocol.respond(json: """
        {"code":200,"status":"OK","data":[{"identifier":"en.sahih","language":"en","name":"Sahih","englishName":"Saheeh International","format":"text","type":"translation","direction":"ltr"}]}
        """)

        // Act
        let edition = try await sut.getSurahEdition()

        // Assert
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.path, "/v1/edition")
        XCTAssertEqual(StubURLProtocol.requests.first?.httpMethod, "GET")
        XCTAssertEqual(edition.data?.first?.identifier, "en.sahih")
        XCTAssertEqual(edition.data?.first?.format, .text)
        XCTAssertEqual(edition.data?.first?.direction, .leftToRight)
    }

    func test_getSurahList_should_requestSurahEndpoint() async throws {
        // Arrange
        StubURLProtocol.respond(json: """
        {"code":200,"status":"OK","data":[{"number":1,"name":"الفاتحة","englishName":"Al-Faatiha","englishNameTranslation":"The Opening","numberOfAyahs":7,"revelationType":"Meccan"}]}
        """)

        // Act
        let list = try await sut.getSurahList()

        // Assert
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.path, "/v1/surah")
        XCTAssertEqual(list.data?.first?.englishName, "Al-Faatiha")
        XCTAssertEqual(list.data?.first?.numberOfAyahs, 7)
    }

    func test_getSurahDetail_should_requestBothEditions() async throws {
        // Arrange
        StubURLProtocol.respond(json: """
        {"code":200,"status":"OK","data":[{"number":18,"englishName":"Al-Kahf","numberOfAyahs":110,"ayahs":[{"number":2141,"audio":"https://cdn/2141.mp3","text":"text","numberInSurah":1,"juz":15,"manzil":4,"page":293,"ruku":1,"hizbQuarter":1}],"edition":{"identifier":"ar.alafasy","format":"audio","direction":"rtl"}}]}
        """)

        // Act
        let surah = try await sut.getSurahDetail(
            surahNo: 18,
            recitationId: "ar.alafasy",
            translationId: "en.sahih"
        )

        // Assert
        XCTAssertEqual(
            StubURLProtocol.requests.first?.url?.absoluteString,
            "https://api.alquran.cloud/v1/surah/18/editions/ar.alafasy,en.sahih"
        )
        XCTAssertEqual(surah.data?.first?.ayahs?.first?.numberInSurah, 1)
        XCTAssertEqual(surah.data?.first?.edition?.format, .audio)
        XCTAssertEqual(surah.data?.first?.edition?.direction, .rightToLeft)
    }

    func test_getSurahList_should_propagateServerError() async {
        // Arrange
        StubURLProtocol.respond(status: 500, json: "{}")

        // Act
        var thrown: Error?
        do {
            _ = try await sut.getSurahList()
        } catch {
            thrown = error
        }

        // Assert
        XCTAssertEqual(thrown as? RequestError, .unexpectedStatusCode)
    }

    func test_surahEndpoints_should_useGetWithoutHeaderOrBody() {
        // Arrange
        let endpoints: [SurahEndpoints] = [
            .getSurahEdition,
            .getSurahList,
            .getSurahDetail(surahNo: 1, recitationId: "a", translationId: "b")
        ]

        // Act
        let methods = endpoints.map(\.method)

        // Assert
        XCTAssertEqual(methods, [.get, .get, .get])
        for endpoint in endpoints {
            XCTAssertNil(endpoint.header)
            XCTAssertNil(endpoint.body)
            XCTAssertEqual(endpoint.scheme, "https")
            XCTAssertEqual(endpoint.host, "api.alquran.cloud")
        }
    }

    func test_requestMethod_should_useHTTPVerbs() {
        // Arrange
        let methods: [RequestMethod] = [.delete, .get, .patch, .post, .put]

        // Act
        let rawValues = methods.map(\.rawValue)

        // Assert
        XCTAssertEqual(rawValues, ["DELETE", "GET", "PATCH", "POST", "PUT"])
    }
}

@MainActor
final class SurahCatalogTests: XCTestCase {
    private var directory: URL!
    private var cacheURL: URL!

    override func setUp() async throws {
        try await super.setUp()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SurahCatalogTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        cacheURL = directory.appendingPathComponent("catalog.json")
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
        try await super.tearDown()
    }

    private func makeSurah(_ number: Int) -> SurahListResponse {
        SurahListResponse(
            number: number,
            name: nil,
            englishName: "Surah \(number)",
            englishNameTranslation: nil,
            numberOfAyahs: 7,
            revelationType: "Meccan"
        )
    }

    func test_init_should_startEmptyWithoutCache() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = SurahCatalog(cacheURL: cacheURL)

        // Assert
        XCTAssertTrue(sut.surahs.isEmpty)
        XCTAssertFalse(sut.isLoaded)
    }

    func test_store_should_keepSurahsAndMarkLoaded() {
        // Arrange
        let sut = SurahCatalog(cacheURL: cacheURL)

        // Act
        sut.store([makeSurah(1), makeSurah(2)])

        // Assert
        XCTAssertEqual(sut.surahs.map(\.number), [1, 2])
        XCTAssertTrue(sut.isLoaded)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cacheURL.path))
    }

    func test_init_should_reloadStoredSurahsFromCache() {
        // Arrange
        SurahCatalog(cacheURL: cacheURL).store([makeSurah(18)])

        // Act
        let sut = SurahCatalog(cacheURL: cacheURL)

        // Assert
        XCTAssertEqual(sut.surahs.map(\.englishName), ["Surah 18"])
        XCTAssertTrue(sut.isLoaded)
    }

    func test_store_should_markEmptyListAsNotLoaded() {
        // Arrange
        let sut = SurahCatalog(cacheURL: cacheURL)
        sut.store([makeSurah(1)])

        // Act
        sut.store([])

        // Assert
        XCTAssertFalse(sut.isLoaded)
        XCTAssertFalse(SurahCatalog(cacheURL: cacheURL).isLoaded)
    }

    func test_init_should_ignoreCorruptCache() throws {
        // Arrange
        try Data("corrupt".utf8).write(to: cacheURL)

        // Act
        let sut = SurahCatalog(cacheURL: cacheURL)

        // Assert
        XCTAssertTrue(sut.surahs.isEmpty)
        XCTAssertFalse(sut.isLoaded)
    }

    func test_store_should_workWithoutCacheURL() {
        // Arrange
        let sut = SurahCatalog(cacheURL: nil)

        // Act
        sut.store([makeSurah(1)])

        // Assert
        XCTAssertTrue(sut.isLoaded)
        XCTAssertEqual(sut.surahs.count, 1)
    }

    func test_shared_should_returnSameInstance() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let shared = SurahCatalog.shared

        // Assert
        XCTAssertTrue(shared === SurahCatalog.shared)
    }
}
