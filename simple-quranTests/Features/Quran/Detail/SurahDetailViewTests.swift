//
//  SurahDetailViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class SurahDetailViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeViewModel(
        store: HidayahStore = makeInMemoryStore()
    ) -> SurahDetailViewModel {
        let viewModel = SurahDetailViewModel(
            surahService: makeStubbedSurahService(),
            store: store
        )
        viewModel.selectedSurahNo = 18
        viewModel.title = "Al-Kahf"
        return viewModel
    }

    private func loadedHost(
        _ viewModel: SurahDetailViewModel
    ) async -> ViewHost<some View> {
        let host = sceneHost(
            NavigationStack { SurahDetailView(viewModel: viewModel) }
        )
        await waitUntil(timeout: 5) { !viewModel.ayahs.isEmpty && !viewModel.recitationItems.isEmpty }
        host.pump(0.6)
        return host
    }

    func test_surahDetailView_should_showAyahsAfterLoading() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()

        // Act
        let host = await loadedHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Al-Kahf means The Cave and consists of 3 verses"))
        XCTAssertTrue(host.contains("Arabic 1"))
        XCTAssertTrue(host.contains("Arabic 3"))
        XCTAssertTrue(host.contains("Translation 2"))
        XCTAssertTrue(host.contains("Alafasy"))
        XCTAssertTrue(host.contains("English"))
        XCTAssertTrue(host.contains("Share ayah"))
        XCTAssertTrue(host.contains("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"))
    }

    func test_surahDetailView_should_showPlaceholderWhileLoading() async {
        // Arrange
        StubURLProtocol.handler = { _ in
            Thread.sleep(forTimeInterval: 0.6)
            throw URLError(.timedOut)
        }
        let viewModel = makeViewModel()

        // Act
        let host = sceneHost(NavigationStack { SurahDetailView(viewModel: viewModel) })
        host.pump(0.1)

        // Assert
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(host.contains("Arabic 1"))
        XCTAssertFalse(host.contains("Share ayah"))

        // Let the slow request finish so it does not delay later tests.
        await waitUntil(timeout: 5) { !viewModel.isLoading }
    }

    func test_surahDetailView_should_hideTranslationWhenTurnedOff() async {
        // Arrange
        Storage.save(.quranShowTranslation, false)
        ViewsFixtures.route()
        let viewModel = makeViewModel()

        // Act
        let host = await loadedHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Arabic 1"))
        XCTAssertFalse(host.contains("Translation 1"))
    }

    func test_surahDetailView_should_showRightToLeftTranslation() async {
        // Arrange
        ViewsFixtures.route(detail: ViewsFixtures.surahDetailJSON(translationDirection: "rtl"))
        let viewModel = makeViewModel()

        // Act
        let host = await loadedHost(viewModel)

        // Assert
        XCTAssertTrue(viewModel.ayahs.allSatisfy(\.translationIsRTL))
        XCTAssertTrue(host.contains("Translation 1"))
    }

    func test_surahDetailView_should_toggleBookmarkWhenTapped() async {
        // Arrange
        ViewsFixtures.route()
        let store = makeInMemoryStore()
        let viewModel = makeViewModel(store: store)
        let host = await loadedHost(viewModel)

        // Act
        host.tap("Bookmark ayah")
        let afterAdd = store.bookmarks()
        let showsRemove = host.contains("Remove bookmark")
        host.tap("Remove bookmark")

        // Assert
        XCTAssertEqual(afterAdd, [SurahBookmark(surahNumber: 18, numberInSurah: 1)])
        XCTAssertTrue(showsRemove)
        XCTAssertTrue(store.bookmarks().isEmpty)
        XCTAssertFalse(host.contains("Remove bookmark"))
    }

    func test_surahDetailView_should_togglePlaybackWhenPlayTapped() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = await loadedHost(viewModel)

        // Act
        host.tap("Play ayah")
        let playing = viewModel.playingAyahID
        let showsPause = host.contains("Pause ayah")
        host.tap("Pause ayah")

        // Assert
        XCTAssertEqual(playing, 1)
        XCTAssertTrue(showsPause)
        XCTAssertNil(viewModel.playingAyahID)
    }

    func test_surahDetailView_should_changeRecitationFromSheet() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = await loadedHost(viewModel)

        // Act
        host.tap("Alafasy")
        host.pump(0.6)
        let sheetShown = host.contains("Choose recitation")
        host.tap("Husary")
        await waitUntil(timeout: 5) {
            !viewModel.isLoading && host.controller.presentedViewController == nil
        }

        // Assert
        XCTAssertTrue(sheetShown)
        XCTAssertEqual(viewModel.reciterName, "Husary")
        let saved: EditionResponse? = Storage.loadObject(key: .selectedRecitation)
        XCTAssertEqual(saved?.identifier, "ar.husary")
        XCTAssertTrue(StubURLProtocol.requests.contains {
            $0.url?.path == "/v1/surah/18/editions/ar.husary,en.asad"
        })
        XCTAssertFalse(host.contains("Choose recitation"))
    }

    func test_surahDetailView_should_changeTranslationFromSheet() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = await loadedHost(viewModel)

        // Act
        host.tap("English")
        host.pump(0.6)
        let sheetShown = host.contains("Choose translation")
        host.tap("Urdu - Jalandhry")
        await waitUntil(timeout: 5) {
            !viewModel.isLoading && host.controller.presentedViewController == nil
        }

        // Assert
        XCTAssertTrue(sheetShown)
        XCTAssertEqual(viewModel.selectedTranslationValue, "ur.jalandhry")
        let saved: EditionResponse? = Storage.loadObject(key: .selectedTranslation)
        XCTAssertEqual(saved?.identifier, "ur.jalandhry")
        XCTAssertTrue(StubURLProtocol.requests.contains {
            $0.url?.path == "/v1/surah/18/editions/ar.alafasy,ur.jalandhry"
        })
    }

    func test_surahDetailView_should_openReadingSettingsFromToolbar() async {
        // Arrange
        ViewsFixtures.route()
        let viewModel = makeViewModel()
        let host = await loadedHost(viewModel)

        // Act
        host.tap("Quran Reading")
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Arabic Text Size"))
        XCTAssertTrue(host.contains("Show Translation"))
    }

    func test_surahDetailView_should_showErrorAlertAndClearItOnOK() async {
        // Arrange
        ViewsFixtures.route(detail: nil)
        let viewModel = makeViewModel()
        let host = sceneHost(NavigationStack { SurahDetailView(viewModel: viewModel) })
        await waitUntil(timeout: 5) { viewModel.errorMessage != nil }
        host.pump(0.6)
        let alertShown = host.contains(ViewsFixtures.serverErrorMessage)

        // Act
        host.tapAlertButton("OK")

        // Assert
        XCTAssertTrue(alertShown)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_surahDetailView_should_scrollToBookmarkedAyah() async {
        // Arrange
        ViewsFixtures.route(detail: ViewsFixtures.surahDetailJSON(ayahCount: 30))
        let viewModel = SurahDetailViewModel(
            surahService: makeStubbedSurahService(),
            bookmarkedAyah: 25,
            scrollToSpecificAyah: true,
            store: makeInMemoryStore()
        )
        viewModel.selectedSurahNo = 18

        // Act
        let host = sceneHost(
            NavigationStack { SurahDetailView(viewModel: viewModel) },
            size: CGSize(width: 402, height: 874)
        )
        await waitUntil(timeout: 5) {
            (host.firstView(of: UIScrollView.self)?.contentOffset.y ?? 0) > 500
        }

        // Assert
        XCTAssertEqual(viewModel.scrollToAyah, 25)
        XCTAssertGreaterThan(host.firstView(of: UIScrollView.self)?.contentOffset.y ?? 0, 500)
    }

    func test_surahDetailScreen_should_loadRequestedSurahAndTitle() {
        // Arrange
        ViewsFixtures.route()

        // Act
        let host = sceneHost(
            NavigationStack {
                SurahDetailScreen(
                    surahService: makeStubbedSurahService(),
                    surahNumber: 18,
                    title: "Cave",
                    bookmarkedAyah: 2
                )
            }
        )
        host.pump(1.5)

        // Assert
        XCTAssertTrue(host.contains("Arabic 2"))
        XCTAssertTrue(host.contains("Al-Kahf"))
        XCTAssertTrue(StubURLProtocol.requests.contains { $0.url?.path == "/v1/surah/18/editions/ar.alafasy,en.asad" })
    }

    func test_surahDetailScreen_should_showErrorForOutOfRangeBookmark() {
        // Arrange
        ViewsFixtures.route()

        // Act
        let host = sceneHost(
            NavigationStack {
                SurahDetailScreen(
                    surahService: makeStubbedSurahService(),
                    surahNumber: 18,
                    title: nil,
                    bookmarkedAyah: 9
                )
            }
        )
        host.pump(1.5)

        // Assert
        XCTAssertTrue(host.contains("Invalid verse number 9. This surah only has 3 verses"))
    }
}
