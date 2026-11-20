//
//  SurahListViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class SurahListViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        super.tearDown()
    }

    func test_init_should_startLoadingWithNoSurahs() {
        // Arrange
        let catalog = SurahCatalog(cacheURL: nil)

        // Act
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )

        // Assert
        XCTAssertTrue(vm.isLoading)
        XCTAssertTrue(vm.surahs.isEmpty)
    }

    func test_loadIfNeeded_should_useCachedCatalogWithoutRequest() {
        // Arrange
        let catalog = SurahCatalog(cacheURL: nil)
        catalog.store(VMFixtures.surahs)
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.surahs.map(\.number), [1, 2, 18, 36])
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func test_loadIfNeeded_should_fetchListAndStoreItInCatalog() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        let catalog = SurahCatalog(cacheURL: nil)
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertEqual(vm.surahs.map(\.englishName), ["Al-Faatiha", "Al-Baqara", "Al-Kahf", "Yaseen"])
        XCTAssertTrue(catalog.isLoaded)
        XCTAssertEqual(catalog.surahs.count, 4)
        XCTAssertEqual(VMFixtures.requestedPaths(), [VMFixtures.surahListPath])
    }

    func test_loadIfNeeded_should_requestOnlyOnceWhenCalledTwice() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: SurahCatalog(cacheURL: nil)
        )

        // Act
        vm.loadIfNeeded()
        vm.loadIfNeeded()
        await waitUntil { !vm.isLoading }
        vm.loadIfNeeded()

        // Assert
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    func test_load_should_setEmptyListWhenDataIsNull() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.nullDataJSON)
        ])
        let catalog = SurahCatalog(cacheURL: nil)
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )

        // Act
        await vm.load()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.surahs.isEmpty)
        XCTAssertFalse(catalog.isLoaded)
    }

    func test_load_should_reportRequestErrorMessageAndClearListWhenCatalogEmpty() async {
        // Arrange
        VMFixtures.route([VMFixtures.surahListPath: (500, "{}")])
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: SurahCatalog(cacheURL: nil)
        )
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        await vm.load()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.surahs.isEmpty)
        XCTAssertEqual(errors, [RequestError.unexpectedStatusCode.message])
    }

    func test_refresh_should_fallBackToCatalogWhenRequestFails() async {
        // Arrange
        let catalog = SurahCatalog(cacheURL: nil)
        catalog.store([VMFixtures.surah(18, "Al-Kahf")])
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        await vm.refresh()

        // Assert
        XCTAssertEqual(vm.surahs.map(\.number), [18])
        XCTAssertEqual(errors.count, 1)
        XCTAssertFalse(errors.first?.isEmpty ?? true)
        XCTAssertFalse(RequestError.vmAllMessages.contains(errors.first ?? ""))
    }

    func test_onSelect_should_beSettableByCoordinator() {
        // Arrange
        let vm = SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: SurahCatalog(cacheURL: nil)
        )
        var selected: Int?
        vm.onSelect = { selected = $0.number }

        // Act
        vm.onSelect?(VMFixtures.surah(36, "Yaseen"))

        // Assert
        XCTAssertEqual(selected, 36)
    }
}

extension RequestError {
    /// Every user-facing request error message, to tell them apart from
    /// system errors surfaced through `localizedDescription`.
    static var vmAllMessages: [String] {
        [
            RequestError.decode, .invalidURL, .noResponse,
            .unauthorized, .unexpectedStatusCode, .unknown
        ].map(\.message)
    }
}
