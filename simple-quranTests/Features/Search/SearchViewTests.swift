//
//  SearchViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class SearchViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeViewModel(
        catalog: SurahCatalog = ViewsFixtures.loadedCatalog(),
        store: HidayahStore = makeInMemoryStore()
    ) -> SearchViewModel {
        let viewModel = SearchViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog,
            store: store
        )
        viewModel.loadIfNeeded()
        return viewModel
    }

    func test_searchView_should_showEmptyStateWithoutKeyword() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        let host = sceneHost(SearchView(viewModel: viewModel))

        // Assert
        XCTAssertTrue(host.contains("No Search Results"))
        XCTAssertTrue(host.contains("Please try type another keyword."))
        XCTAssertFalse(host.contains("Al-Baqara"))
    }

    func test_searchView_should_showMatchingSurahsAndBookmarks() {
        // Arrange
        let store = makeInMemoryStore()
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        let viewModel = makeViewModel(store: store)
        let host = sceneHost(SearchView(viewModel: viewModel))

        // Act
        viewModel.updateKeyword("kahf")
        host.pump(0.2)

        // Assert
        XCTAssertTrue(host.contains("Bookmark"))
        XCTAssertTrue(host.contains("Verse 10"))
        XCTAssertTrue(host.contains("Surah"))
        XCTAssertTrue(host.contains("Makkiyah • 110 verses"))
        XCTAssertFalse(host.contains("Al-Baqara"))
    }

    func test_searchView_should_showOnlySurahSectionWhenNoBookmarkMatches() {
        // Arrange
        let viewModel = makeViewModel()
        let host = sceneHost(SearchView(viewModel: viewModel))

        // Act
        viewModel.updateKeyword("baqara")
        host.pump(0.2)

        // Assert
        XCTAssertTrue(host.contains("Madaniyah • 286 verses"))
        XCTAssertFalse(host.contains("Verse "))
    }

    func test_searchView_should_showEmptyStateWhenNothingMatches() {
        // Arrange
        let viewModel = makeViewModel()
        let host = sceneHost(SearchView(viewModel: viewModel))

        // Act
        viewModel.updateKeyword("zzz")
        host.pump(0.2)

        // Assert
        XCTAssertTrue(host.contains("No Search Results"))
    }

    func test_searchView_should_showPlaceholdersWhileLoading() async {
        // Arrange
        StubURLProtocol.handler = { _ in
            Thread.sleep(forTimeInterval: 0.6)
            throw URLError(.timedOut)
        }

        // Act
        let viewModel = makeViewModel(catalog: ViewsFixtures.emptyCatalog())
        let host = sceneHost(SearchView(viewModel: viewModel))
        host.pump(0.1)

        // Assert
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(host.contains("No Search Results"))

        // Let the slow request finish so it does not delay later tests.
        await waitUntil(timeout: 5) { !viewModel.isLoading }
    }

    func test_searchView_should_callSelectionHandlers() {
        // Arrange
        let store = makeInMemoryStore()
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        let viewModel = makeViewModel(store: store)
        var selectedSurahs: [Int] = []
        var selectedBookmarks: [String] = []
        viewModel.onSelectSurah = { selectedSurahs.append($0.number ?? 0) }
        viewModel.onSelectBookmark = { selectedBookmarks.append($0.id) }
        viewModel.updateKeyword("kahf")
        let host = sceneHost(SearchView(viewModel: viewModel))

        // Act
        host.tap("Verse 10")
        host.tap("110 verses")

        // Assert
        XCTAssertEqual(selectedBookmarks, ["18-10"])
        XCTAssertEqual(selectedSurahs, [18])
    }
}
