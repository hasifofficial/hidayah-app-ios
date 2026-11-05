//
//  BookmarkListViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class BookmarkListViewModelTests: XCTestCase {
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

    private func makeViewModel() -> BookmarkListViewModel {
        BookmarkListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog,
            store: store
        )
    }

    func test_loadIfNeeded_should_hydrateSortedBookmarksFromCachedCatalog() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 255))
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 1))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.bookmarks.map(\.id), ["2-255", "18-1", "18-10"])
        XCTAssertEqual(vm.bookmarks.map(\.surah.englishName), ["Al-Baqara", "Al-Kahf", "Al-Kahf"])
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func test_loadIfNeeded_should_dropBookmarksForUnknownSurahs() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 114, numberInSurah: 1))
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 3))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertEqual(vm.bookmarks.map(\.id), ["36-3"])
    }

    func test_loadIfNeeded_should_fetchListWhenCatalogEmpty() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.surahListJSON())
        ])
        store.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 7))
        let vm = makeViewModel()

        // Act
        vm.loadIfNeeded()
        await waitUntil { !vm.isLoading }

        // Assert
        XCTAssertEqual(vm.bookmarks.map(\.id), ["1-7"])
        XCTAssertTrue(catalog.isLoaded)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    func test_loadIfNeeded_should_rehydrateWithoutRequestOnSecondCall() {
        // Arrange
        catalog.store(VMFixtures.surahs)
        let vm = makeViewModel()
        vm.loadIfNeeded()
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 1))

        // Act
        vm.loadIfNeeded()

        // Assert
        XCTAssertEqual(vm.bookmarks.map(\.id), ["36-1"])
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func test_load_should_clearBookmarksWhenListIsEmpty() async {
        // Arrange
        VMFixtures.route([
            VMFixtures.surahListPath: (200, VMFixtures.nullDataJSON)
        ])
        store.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 1))
        let vm = makeViewModel()

        // Act
        await vm.load()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.bookmarks.isEmpty)
    }

    func test_refresh_should_clearBookmarksAndReportErrorWhenRequestFails() async {
        // Arrange
        catalog.store(VMFixtures.surahs)
        store.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 1))
        let vm = makeViewModel()
        vm.loadIfNeeded()
        VMFixtures.route([VMFixtures.surahListPath: (401, "{}")])
        var errors: [String] = []
        vm.onError = { errors.append($0) }

        // Act
        await vm.refresh()

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.bookmarks.isEmpty)
        XCTAssertEqual(errors, [RequestError.unauthorized.message])
    }

    func test_onSelect_should_receiveSelectedBookmark() {
        // Arrange
        let vm = makeViewModel()
        let item = BookmarkedSurah(
            surah: VMFixtures.surah(18, "Al-Kahf"),
            bookmark: SurahBookmark(surahNumber: 18, numberInSurah: 10)
        )
        var selected: String?
        vm.onSelect = { selected = $0.id }

        // Act
        vm.onSelect?(item)

        // Assert
        XCTAssertEqual(selected, "18-10")
    }
}
