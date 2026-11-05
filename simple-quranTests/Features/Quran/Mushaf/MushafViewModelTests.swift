//
//  MushafViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class MushafViewModelTests: XCTestCase {
    private func makeViewModel(
        surah: Int = 2,
        ayah: Int? = nil,
        loader: FakeMushafLoader = FakeMushafLoader(),
        catalog: SurahCatalog = SurahCatalog(cacheURL: nil),
        store: HidayahStore = makeInMemoryStore()
    ) -> MushafViewModel {
        MushafViewModel(
            surahNumber: surah,
            ayahNumber: ayah,
            loader: loader,
            catalog: catalog,
            store: store
        )
    }

    func test_loadIfNeeded_should_openOnSurahStartPage() {
        // Arrange
        let viewModel = makeViewModel(surah: 2)

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.startPage, 2)
        XCTAssertEqual(viewModel.scrolledPage, 2)
        XCTAssertEqual(viewModel.currentPage, 2)
    }

    func test_loadIfNeeded_should_openOnAyahPage_when_ayahIsGiven() {
        // Arrange
        let viewModel = makeViewModel(surah: 2, ayah: 7)

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.currentPage, 3)
    }

    func test_loadIfNeeded_should_useSurahStart_when_ayahIsZero() {
        // Arrange
        let viewModel = makeViewModel(surah: 3, ayah: 0)

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.currentPage, 4)
    }

    func test_loadIfNeeded_should_keepPage_when_calledAgain() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()
        viewModel.scrolledPage = 4

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.currentPage, 4)
    }

    func test_loadIfNeeded_should_exposeError_when_layoutFails() {
        // Arrange
        let loader = FakeMushafLoader()
        loader.layoutResult = .failure(.corrupt)
        let viewModel = makeViewModel(loader: loader)

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.loadError, .corrupt)
        XCTAssertNil(viewModel.layout)
        XCTAssertEqual(viewModel.currentPage, 1)
    }

    func test_retry_should_load_when_layoutRecovers() {
        // Arrange
        let loader = FakeMushafLoader()
        loader.layoutResult = .failure(.missingResource)
        let viewModel = makeViewModel(loader: loader)
        viewModel.loadIfNeeded()
        loader.layoutResult = .success(MushafFixtures.layout())

        // Act
        viewModel.retry()

        // Assert
        XCTAssertNil(viewModel.loadError)
        XCTAssertEqual(viewModel.currentPage, 2)
    }

    func test_pageDetails_should_followLayout() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()

        // Act
        let surahs = viewModel.surahs(onPage: 3)
        let juz = viewModel.juz(onPage: 3)

        // Assert
        XCTAssertEqual(surahs, [2])
        XCTAssertEqual(juz, 2)
    }

    func test_pageDetails_should_fallBack_when_layoutIsMissing() {
        // Arrange
        let viewModel = makeViewModel(surah: 18)

        // Act
        let surahs = viewModel.surahs(onPage: 9)
        let juz = viewModel.juz(onPage: 9)

        // Assert
        XCTAssertEqual(surahs, [18])
        XCTAssertEqual(juz, 1)
    }

    func test_accessibilityLabel_should_nameSurahsFromCatalog() {
        // Arrange
        let catalog = SurahCatalog(cacheURL: nil)
        catalog.store(VMFixtures.surahs)
        let viewModel = makeViewModel(catalog: catalog)
        viewModel.loadIfNeeded()

        // Act
        let label = viewModel.accessibilityLabel(forPage: 2)

        // Assert
        XCTAssertEqual(label, "Page 2, \(viewModel.surahName(2)), Juz 1")
        XCTAssertNotEqual(viewModel.surahName(2), "Surah 2")
    }

    func test_surahName_should_fallBackToNumber_when_catalogIsEmpty() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        let name = viewModel.surahName(99)

        // Assert
        XCTAssertEqual(name, "Surah 99")
    }

    func test_image_should_decodeOnceAndReuseCache() async {
        // Arrange
        let loader = FakeMushafLoader()
        let viewModel = makeViewModel(loader: loader)

        // Act
        let first = await viewModel.image(forPage: 2, maxPixelWidth: 40)
        let second = await viewModel.image(forPage: 2, maxPixelWidth: 40)

        // Assert
        XCTAssertNotNil(first)
        XCTAssertTrue(first === second)
        XCTAssertEqual(loader.imageRequests, [2])
    }

    // MARK: Bookmarks

    func test_toggleBookmark_should_bookmarkFirstAyahOfPage() {
        // Arrange
        let store = makeInMemoryStore()
        let viewModel = makeViewModel(store: store)
        viewModel.loadIfNeeded()

        // Act
        viewModel.toggleBookmark(page: 3)

        // Assert
        XCTAssertEqual(store.bookmarks(), [SurahBookmark(surahNumber: 2, numberInSurah: 6)])
        XCTAssertTrue(viewModel.isBookmarked(page: 3))
        XCTAssertFalse(viewModel.isBookmarked(page: 2))
    }

    func test_toggleBookmark_should_clearEveryBookmarkOnPage() {
        // Arrange
        let store = makeInMemoryStore()
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 2))
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 4))
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 9))
        let viewModel = makeViewModel(store: store)
        viewModel.loadIfNeeded()

        // Act
        viewModel.toggleBookmark(page: 2)

        // Assert
        XCTAssertEqual(store.bookmarks(), [SurahBookmark(surahNumber: 2, numberInSurah: 9)])
        XCTAssertFalse(viewModel.isBookmarked(page: 2))
        XCTAssertTrue(viewModel.isBookmarked(page: 3))
    }

    func test_refreshBookmarks_should_pickUpListModeBookmarks() {
        // Arrange
        let store = makeInMemoryStore()
        let viewModel = makeViewModel(store: store)
        viewModel.loadIfNeeded()
        store.toggleBookmark(SurahBookmark(surahNumber: 3, numberInSurah: 20))

        // Act
        viewModel.refreshBookmarks()

        // Assert
        XCTAssertEqual(viewModel.bookmarkedPages, [4])
        XCTAssertTrue(viewModel.accessibilityLabel(forPage: 4).hasSuffix("Juz 2, bookmarked"))
        XCTAssertFalse(viewModel.accessibilityLabel(forPage: 3).hasSuffix("bookmarked"))
    }

    func test_toggleBookmark_should_doNothing_when_layoutIsMissing() {
        // Arrange
        let store = makeInMemoryStore()
        let viewModel = makeViewModel(store: store)

        // Act
        viewModel.toggleBookmark(page: 2)

        // Assert
        XCTAssertTrue(store.bookmarks().isEmpty)
    }
}
