//
//  SearchViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var store: HidayahStore!
    private var catalog: SurahCatalog!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        store = makeInMemoryStore()
        catalog = SurahCatalog(cacheURL: nil)
    }

    override func tearDown() {
        StubURLProtocol.reset()
        store = nil
        catalog = nil
        super.tearDown()
    }

    private func makeViewModel() -> SearchViewModel {
        SearchViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog,
            store: store
        )
    }

    func test_init_should_startEmptyAndIdle() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = makeViewModel()

        // Assert
        XCTAssertEqual(vm.keyword, "")
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.surahList.isEmpty)
        XCTAssertTrue(vm.filteredSurahList.isEmpty)
    }

    func test_loadIfNeeded_should_useCachedCatalogAndBookmarksWithoutRequest() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 2))
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 5))
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 3))
        store.toggleBookmark(SurahBookmark(surahNumber: 99, numberInSurah: 1))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertEqual(vm.surahList.count, 4)
        XCTAssertEqual(vm.bookmarkedSurahs.map(\.id), ["2-3", "2-5", "36-2"])
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func test_loadIfNeeded_should_fetchListWhenCatalogEmpty() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        let loadingAfterCall = vm.isLoading
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertTrue(loadingAfterCall)
        XCTAssertEqual(vm.surahList.count, 4)
        XCTAssertEqual(vm.bookmarkedSurahs.map(\.id), ["18-10"])
        XCTAssertTrue(catalog.isLoaded)
    }

    func test_loadIfNeeded_should_onlyRefreshBookmarksAfterFirstLoad() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        let vm = makeViewModel()
        vm.loadIfNeeded()
        await waitUntil { !vm.isLoading }
        store.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 1))

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertEqual(vm.bookmarkedSurahs.map(\.id), ["1-1"])
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    func test_load_should_ignoreCallWhileAlreadyLoading() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        let vm = makeViewModel()

        // Act
        vm.load()
        vm.load()
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    func test_load_should_reportErrorAndStopLoadingWhenRequestFails() async {
        // Arrange
        VMFixtures.route([VMFixtures.surahListPath: (503, "{}")])
        let vm = makeViewModel()
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        vm.load()
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertEqual(errors, [RequestError.unexpectedStatusCode.message])
        XCTAssertTrue(vm.surahList.isEmpty)
    }

    func test_load_should_handleNullDataAsEmptyList() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.nullDataJSON)
        ])
        let vm = makeViewModel()
        vm.updateKeyword("al")

        // Act
        vm.load()
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertTrue(vm.surahList.isEmpty)
        XCTAssertTrue(vm.bookmarkedSurahs.isEmpty)
        XCTAssertTrue(vm.filteredSurahList.isEmpty)
    }

    func test_updateKeyword_should_filterSurahsCaseInsensitively() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        let vm = makeViewModel()
        vm.loadIfNeeded()

        // Act
        vm.updateKeyword("  KAHF ")

        // Assert
        XCTAssertEqual(vm.keyword, "  KAHF ")
        XCTAssertEqual(vm.filteredSurahList.map(\.number), [18])
    }

    func test_updateKeyword_should_matchSubstringAcrossSurahs() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        let vm = makeViewModel()
        vm.loadIfNeeded()

        // Act
        vm.updateKeyword("al-")

        // Assert
        XCTAssertEqual(vm.filteredSurahList.map(\.number), [1, 2, 18])
    }

    func test_updateKeyword_should_filterBookmarksBySurahName() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 1))
        let vm = makeViewModel()
        vm.loadIfNeeded()

        // Act
        vm.updateKeyword("yaseen")

        // Assert
        XCTAssertEqual(vm.filteredBookmarkedSurahs.map(\.id), ["36-1"])
    }

    func test_updateKeyword_should_clearResultsForBlankKeyword() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        let vm = makeViewModel()
        vm.loadIfNeeded()
        vm.updateKeyword("kahf")

        // Act
        vm.updateKeyword(" \n ")

        // Assert
        XCTAssertTrue(vm.filteredSurahList.isEmpty)
        XCTAssertTrue(vm.filteredBookmarkedSurahs.isEmpty)
    }

    func test_updateKeyword_should_skipSurahsWithoutEnglishName() {
        // Arrange
        catalog.store([VMFixtures.surah(1, nil), VMFixtures.surah(2, "Al-Baqara")])
        store.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 1))
        let vm = makeViewModel()
        vm.loadIfNeeded()

        // Act
        vm.updateKeyword("a")

        // Assert
        XCTAssertEqual(vm.filteredSurahList.map(\.number), [2])
        XCTAssertTrue(vm.filteredBookmarkedSurahs.isEmpty)
    }

    func test_refreshBookmarks_should_reapplyActiveKeyword() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        let vm = makeViewModel()
        vm.loadIfNeeded()
        vm.updateKeyword("kahf")
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 4))

        // Act
        vm.refreshBookmarks()

        // Assert
        XCTAssertEqual(vm.filteredBookmarkedSurahs.map(\.id), ["18-4"])
    }

    func test_refreshBookmarks_should_clearBookmarksWhenListEmpty() {
        // Arrange
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 4))
        let vm = makeViewModel()
        vm.bookmarkedSurahs = [
            SearchBookmark(
                surah: VMFixtures.surah(18, "Al-Kahf"),
                bookmark: SurahBookmark(surahNumber: 18, numberInSurah: 4)
            )
        ]

        // Act
        vm.refreshBookmarks()

        // Assert
        XCTAssertTrue(vm.bookmarkedSurahs.isEmpty)
    }

    func test_searchBookmarkID_should_fallBackToZeroForMissingSurahNumber() {
        // Arrange
        let surah = SurahListResponse(
            number: nil,
            name: nil,
            englishName: nil,
            englishNameTranslation: nil,
            numberOfAyahs: nil,
            revelationType: nil
        )

        // Act
        let item = SearchBookmark(
            surah: surah,
            bookmark: SurahBookmark(surahNumber: 5, numberInSurah: 3)
        )

        // Assert
        XCTAssertEqual(item.id, "0-3")
    }
}
