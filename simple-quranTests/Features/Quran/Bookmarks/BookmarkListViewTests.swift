//
//  BookmarkListViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class BookmarkListViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeViewModel(
        catalog: SurahCatalog = ViewsFixtures.loadedCatalog(),
        store: HidayahStore
    ) -> BookmarkListViewModel {
        BookmarkListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog,
            store: store
        )
    }

    func test_bookmarkListView_should_showSavedBookmarks() {
        // Arrange
        let store = makeInMemoryStore()
        store.toggleBookmark(SurahBookmark(surahNumber: 2, numberInSurah: 255))
        store.toggleBookmark(SurahBookmark(surahNumber: 18, numberInSurah: 10))
        let viewModel = makeViewModel(store: store)

        // Act
        let host = sceneHost(NavigationStack { BookmarkListView(viewModel: viewModel) })
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Saved Ayahs"))
        XCTAssertTrue(host.contains("2 saved ayahs"))
        XCTAssertTrue(host.contains("Al-Baqara"))
        XCTAssertTrue(host.contains("Verse 255"))
        XCTAssertTrue(host.contains("Al-Kahf"))
        XCTAssertTrue(host.contains("Verse 10"))
    }

    func test_bookmarkListView_should_showRemainingRows_when_bookmarksShrinkDuringRefresh() async throws {
        // Arrange
        ViewsFixtures.route()
        let store = makeInMemoryStore()
        let bookmarks = [
            SurahBookmark(surahNumber: 2, numberInSurah: 255),
            SurahBookmark(surahNumber: 18, numberInSurah: 10),
            SurahBookmark(surahNumber: 36, numberInSurah: 1)
        ]
        bookmarks.forEach { store.toggleBookmark($0) }
        let viewModel = makeViewModel(store: store)
        let host = sceneHost(NavigationStack { BookmarkListView(viewModel: viewModel) })
        host.pump(0.6)
        store.toggleBookmark(bookmarks[1])
        store.toggleBookmark(bookmarks[2])

        // Act
        let refreshControl = try XCTUnwrap(host.window.firstSubview(of: UIRefreshControl.self))
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        await waitUntil(timeout: 5) { viewModel.bookmarks.count == 1 && !viewModel.isLoading }
        host.pump(0.6)

        // Assert
        XCTAssertEqual(viewModel.bookmarks.map(\.id), ["2-255"])
        XCTAssertTrue(host.contains("Al-Baqara"))
        XCTAssertFalse(host.contains("Al-Kahf"))
        XCTAssertFalse(host.contains("Yaseen"))
    }

    func test_bookmarkListView_should_showEmptyStateWithoutBookmarks() {
        // Arrange
        let viewModel = makeViewModel(store: makeInMemoryStore())

        // Act
        let host = sceneHost(NavigationStack { BookmarkListView(viewModel: viewModel) })
        host.pump()

        // Assert
        XCTAssertTrue(host.contains("You have no bookmarks"))
        XCTAssertTrue(host.contains("Tap on bookmark icon when reading to add bookmark"))
    }

    func test_bookmarkListView_should_showPlaceholdersWhileLoading() async {
        // Arrange
        StubURLProtocol.handler = { _ in
            Thread.sleep(forTimeInterval: 0.6)
            throw URLError(.timedOut)
        }
        let viewModel = makeViewModel(
            catalog: ViewsFixtures.emptyCatalog(),
            store: makeInMemoryStore()
        )

        // Act
        let host = sceneHost(NavigationStack { BookmarkListView(viewModel: viewModel) })
        host.pump(0.1)

        // Assert
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(host.contains("You have no bookmarks"))
        XCTAssertFalse(host.contains("Saved Ayahs"))

        // Let the slow request finish so it does not delay later tests.
        await waitUntil(timeout: 5) { !viewModel.isLoading }
    }

    func test_bookmarkListView_should_reportErrorAndShowEmptyStateWhenLoadFails() async {
        // Arrange
        ViewsFixtures.route(list: nil)
        let viewModel = makeViewModel(
            catalog: ViewsFixtures.emptyCatalog(),
            store: makeInMemoryStore()
        )
        var errors: [String] = []
        viewModel.onError = { errors.append($0) }

        // Act
        let host = sceneHost(NavigationStack { BookmarkListView(viewModel: viewModel) })
        await waitUntil(timeout: 5) { !viewModel.isLoading }
        host.pump()

        // Assert
        XCTAssertEqual(errors, [ViewsFixtures.serverErrorMessage])
        XCTAssertTrue(host.contains("You have no bookmarks"))
    }

    func test_bookmarkListView_should_callOnSelectAndSettings() {
        // Arrange
        let store = makeInMemoryStore()
        store.toggleBookmark(SurahBookmark(surahNumber: 36, numberInSurah: 12))
        let viewModel = makeViewModel(store: store)
        var selected: [String] = []
        var settingsOpened = 0
        let host = sceneHost(
            NavigationStack {
                BookmarkListView(
                    viewModel: viewModel,
                    onSelect: { selected.append($0.id) },
                    onOpenSettings: { settingsOpened += 1 }
                )
            }
        )
        host.pump(0.6)

        // Act
        host.tap("Yaseen")
        host.tap("More")

        // Assert
        XCTAssertEqual(selected, ["36-12"])
        XCTAssertEqual(settingsOpened, 1)
    }
}

private extension UIView {
    /// The first view of `type` in this view's hierarchy, depth first.
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }
        for subview in subviews {
            if let match = subview.firstSubview(of: type) {
                return match
            }
        }
        return nil
    }
}
