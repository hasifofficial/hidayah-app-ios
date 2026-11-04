//
//  MushafViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class MushafViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func makeHost(
        _ viewModel: MushafViewModel,
        size: CGSize = CGSize(width: 402, height: 874)
    ) -> ViewHost<some View> {
        let host = sceneHost(
            NavigationStack { MushafView(viewModel: viewModel) },
            size: size
        )
        host.pump(0.6)
        return host
    }

    func test_mushafView_should_openOnSurahPage() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader())

        // Act
        let host = makeHost(viewModel)

        // Assert
        XCTAssertTrue(host.contains("Page 2, "))
        XCTAssertTrue(host.contains("Juz 1"))
        XCTAssertEqual(viewModel.currentPage, 2)
    }

    func test_mushafView_should_followPage_when_scrolled() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 1, loader: FakeMushafLoader())
        let host = makeHost(viewModel)

        // Act
        viewModel.scrolledPage = 3
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Juz 2"))
        XCTAssertTrue(host.contains("Page 3, "))
    }

    func test_mushafView_should_showBundledPages() async {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 18)

        // Act
        let host = makeHost(viewModel)
        await waitUntil(timeout: 5) { host.firstView(of: UIScrollView.self) != nil }
        host.pump(0.6)

        // Assert
        XCTAssertEqual(viewModel.currentPage, 293)
        XCTAssertTrue(host.contains("Juz 15"))
    }

    func test_mushafView_should_showErrorAndRetry() {
        // Arrange
        let loader = FakeMushafLoader()
        loader.layoutResult = .failure(.missingResource)
        let viewModel = MushafViewModel(surahNumber: 2, loader: loader)
        let host = makeHost(viewModel)
        let showedError = host.contains("The Mushaf pages couldn't be loaded.")
        loader.layoutResult = .success(MushafFixtures.layout())

        // Act
        host.tap("Try Again")
        host.pump(0.4)

        // Assert
        XCTAssertTrue(showedError)
        XCTAssertNil(viewModel.loadError)
        XCTAssertTrue(host.contains("Page 2, "))
    }

    func test_mushafView_should_openReadingSettingsWithModePicker() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader())
        let host = makeHost(viewModel)

        // Act
        host.tap("Quran Reading")
        host.pump(0.8)

        // Assert
        XCTAssertTrue(host.contains("Reading Mode"))
        XCTAssertTrue(host.contains("Mushaf"))
    }

    // MARK: Spreads

    func test_showsSpread_should_needWideEnoughScreen() {
        // Arrange
        let sizes = [
            CGSize(width: 402, height: 700),  // iPhone upright
            CGSize(width: 466, height: 520),  // iPhone Duo folded
            CGSize(width: 669, height: 760),  // iPhone Duo unfolded
            CGSize(width: 1024, height: 640), // iPad landscape
            CGSize(width: 640, height: 1180), // tall and narrow
            .zero
        ]

        // Act
        let spreads = sizes.map(MushafView.showsSpread(in:))

        // Assert
        XCTAssertEqual(spreads, [false, false, true, true, false, false])
    }

    func test_mushafView_should_showTwoPages_when_unfolded() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader())

        // Act
        let host = makeHost(viewModel, size: CGSize(width: 669, height: 951))

        // Assert
        let pager = host.firstView(of: UIScrollView.self)
        XCTAssertTrue(host.contains("Page 1, "))
        XCTAssertTrue(host.contains("Page 2, "))
        XCTAssertEqual(viewModel.currentPage, 2)
        // Four pages make two spreads, each one screen wide.
        XCTAssertEqual(pager?.contentSize.width ?? 0, 2 * 669, accuracy: 1)
    }

    func test_mushafView_should_moveBySpread_when_scrolled() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 1, loader: FakeMushafLoader())
        let host = makeHost(viewModel, size: CGSize(width: 669, height: 951))

        // Act
        viewModel.scrolledPage = 3
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Page 3, "))
        XCTAssertTrue(host.contains("Page 4, "))
        XCTAssertTrue(host.contains("Juz 1"))
    }

    func test_mushafView_should_showOnePage_when_spreadsAreOff() {
        // Arrange
        Storage.save(.mushafShowsSpread, false)
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader())

        // Act
        let host = makeHost(viewModel, size: CGSize(width: 669, height: 951))

        // Assert
        let pager = host.firstView(of: UIScrollView.self)
        XCTAssertEqual(pager?.contentSize.width ?? 0, 4 * 669, accuracy: 1)
    }

    func test_mushafView_should_showOnePage_when_folded() {
        // Arrange
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader())

        // Act
        let host = makeHost(viewModel, size: CGSize(width: 466, height: 678))

        // Assert
        let pager = host.firstView(of: UIScrollView.self)
        XCTAssertTrue(host.contains("Page 2, "))
        XCTAssertEqual(pager?.contentSize.width ?? 0, 4 * 466, accuracy: 1)
    }

    // MARK: Bookmarks

    func test_mushafView_should_bookmarkPage_when_buttonIsTapped() {
        // Arrange
        let store = makeInMemoryStore()
        let viewModel = MushafViewModel(surahNumber: 2, loader: FakeMushafLoader(), store: store)
        let host = makeHost(viewModel)

        // Act
        host.tap("Bookmark page 2")
        host.pump(0.3)

        // Assert
        XCTAssertEqual(store.bookmarks(), [SurahBookmark(surahNumber: 2, numberInSurah: 1)])
        XCTAssertTrue(host.contains("Remove bookmark from page 2"))
    }

    func test_mushafView_should_offerBookmarkForEachPageOfSpread() {
        // Arrange
        let store = makeInMemoryStore()
        let viewModel = MushafViewModel(surahNumber: 1, loader: FakeMushafLoader(), store: store)
        let host = makeHost(viewModel, size: CGSize(width: 669, height: 951))

        // Act
        host.tap("Bookmark page 2")
        host.pump(0.3)

        // Assert
        XCTAssertTrue(host.contains("Bookmark page 1"))
        XCTAssertTrue(host.contains("Remove bookmark from page 2"))
        XCTAssertEqual(store.bookmarks(), [SurahBookmark(surahNumber: 2, numberInSurah: 1)])
    }
}
