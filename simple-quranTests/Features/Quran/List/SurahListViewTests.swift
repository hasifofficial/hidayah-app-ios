//
//  SurahListViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class SurahListViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeViewModel(
        catalog: SurahCatalog = ViewsFixtures.emptyCatalog()
    ) -> SurahListViewModel {
        SurahListViewModel(
            surahService: makeStubbedSurahService(),
            catalog: catalog
        )
    }

    func test_surahListView_should_showSurahNamesAfterLoading() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()

        // Act
        let host = sceneHost(NavigationStack { SurahListView(viewModel: viewModel) })
        await waitUntil(timeout: 5) { !viewModel.isLoading }
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Al-Baqara"))
        XCTAssertTrue(host.contains("Madaniyah • 286 verses"))
        XCTAssertTrue(host.contains("Makkiyah • 7 verses"))
        XCTAssertTrue(host.contains("All Surahs"))
        XCTAssertTrue(host.contains("7 surahs"))
        XCTAssertTrue(host.contains("Quick Access"))
        XCTAssertTrue(host.contains("Al-Mulk, "))
    }

    func test_surahListView_should_readArabicNames_when_drawnWithSurahNameFont() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()

        // Act
        let host = sceneHost(NavigationStack { SurahListView(viewModel: viewModel) })
        await waitUntil(timeout: 5) { !viewModel.isLoading }
        host.pump(0.6)

        // Assert
        // SwiftUI wraps the interpolated Arabic in direction isolates, so
        // check the parts rather than the exact label.
        let cardLabel = host.labels().first { $0.hasPrefix("Al-Mulk, ") }
        XCTAssertTrue(cardLabel?.contains("سورة الملك") == true, "\(cardLabel ?? "no card")")
        XCTAssertTrue(host.contains("Al-Mulk, Makkiyah • 30 verses, سورة الملك"))
        XCTAssertFalse(host.labels().contains { $0.contains("surah0") || $0.contains("surah1") })
    }

    func test_surahListView_should_showPlaceholdersWhileLoading() async {
        // Arrange
        StubURLProtocol.handler = { _ in
            Thread.sleep(forTimeInterval: 0.6)
            throw URLError(.timedOut)
        }
        let viewModel = makeViewModel()

        // Act
        let host = sceneHost(NavigationStack { SurahListView(viewModel: viewModel) })
        host.pump(0.1)

        // Assert
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(host.contains("All Surahs"))
        XCTAssertFalse(host.contains("Oops!"))

        // Let the slow request finish so it does not delay later tests.
        await waitUntil(timeout: 5) { !viewModel.isLoading }
    }

    func test_surahListView_should_showEmptyStateWhenLoadingFails() async {
        // Arrange
        ViewsFixtures.route(list: nil)
        let viewModel = makeViewModel()
        var errors: [String] = []
        viewModel.onError = { errors.append($0) }

        // Act
        let host = sceneHost(NavigationStack { SurahListView(viewModel: viewModel) })
        await waitUntil(timeout: 5) { !viewModel.isLoading }
        host.pump()

        // Assert
        XCTAssertTrue(host.contains("Oops!"))
        XCTAssertTrue(host.contains("Something went wrong."))
        XCTAssertEqual(errors, [ViewsFixtures.serverErrorMessage])
    }

    func test_surahListView_should_callOnSelectWhenRowTapped() {
        // Arrange
        let viewModel = makeViewModel(catalog: ViewsFixtures.loadedCatalog())
        var selected: [Int] = []
        let host = sceneHost(
            NavigationStack {
                SurahListView(
                    viewModel: viewModel,
                    onSelect: { selected.append($0.number ?? 0) }
                )
            }
        )
        host.pump(0.6)

        // Act
        host.tap("Al-Baqara")
        host.tap("Yaseen, ")

        // Assert
        XCTAssertEqual(selected, [2, 36])
    }

    func test_surahListView_should_callToolbarActions() {
        // Arrange
        let viewModel = makeViewModel(catalog: ViewsFixtures.loadedCatalog())
        var bookmarksOpened = 0
        var settingsOpened = 0
        let host = sceneHost(
            NavigationStack {
                SurahListView(
                    viewModel: viewModel,
                    onOpenBookmarks: { bookmarksOpened += 1 },
                    onOpenSettings: { settingsOpened += 1 }
                )
            }
        )

        // Act
        host.tap("Bookmarks")
        host.tap("More")

        // Assert
        XCTAssertEqual(bookmarksOpened, 1)
        XCTAssertEqual(settingsOpened, 1)
    }

    func test_surahListView_should_reloadWhenPulledToRefresh() async {
        // Arrange
        // Same number of rows as before: the list's index-based ForEach can
        // read a stale index while rows change (BookmarkListView crashed
        // that way under test), so the row count is kept stable here.
        var rows = ViewsFixtures.surahs
        let last = rows.removeLast()
        rows.append(.init(number: last.number, englishName: "The Sovereignty", arabic: last.arabic, ayahs: last.ayahs, revelation: last.revelation))
        ViewsFixtures.route(list: ViewsFixtures.surahListJSON(rows))
        let viewModel = makeViewModel(catalog: ViewsFixtures.loadedCatalog())
        let host = sceneHost(NavigationStack { SurahListView(viewModel: viewModel) })
        let before = host.contains("The Sovereignty")

        // Act
        host.pullToRefresh()
        await waitUntil(timeout: 5) { viewModel.surahs.last?.englishName == "The Sovereignty" }
        host.pump(0.3)

        // Assert
        XCTAssertFalse(before)
        XCTAssertTrue(host.contains("The Sovereignty"))
        XCTAssertTrue(StubURLProtocol.requests.contains { $0.url?.path == "/v1/surah" })
    }
}
