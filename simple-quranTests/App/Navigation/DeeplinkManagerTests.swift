//
//  DeeplinkManagerTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class DeeplinkManagerTests: XCTestCase {
    private var router: AppRouter!
    private var sut: DeeplinkManager!

    override func setUp() async throws {
        try await super.setUp()
        router = AppRouter()
        sut = DeeplinkManager(router: router)
    }

    override func tearDown() async throws {
        router = nil
        sut = nil
        try await super.tearDown()
    }

    private func handle(_ string: String) -> Bool {
        sut.handleDeepLink(url: URL(string: string)!)
    }

    func test_handleDeepLink_should_openQuranTab() {
        // Arrange
        router.selectTab(.tracker)
        router.settingsPresented = true

        // Act
        let handled = handle("hidayahapp://inAppDeeplink/quran")

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertTrue(router.quranPath.isEmpty)
        XCTAssertFalse(router.settingsPresented)
    }

    func test_handleDeepLink_should_openSurahDetail() {
        // Arrange
        router.selectTab(.tracker)

        // Act
        let handled = handle("hidayahapp://inAppDeeplink/quran/18")

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertEqual(
            router.quranPath,
            [.surahDetail(surahNumber: 18, title: nil, bookmarkedAyah: nil)]
        )
    }

    func test_handleDeepLink_should_openSurahDetailAtAyah() {
        // Arrange
        let url = "hidayahapp://inAppDeeplink/quran/2/255"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(
            router.quranPath,
            [.surahDetail(surahNumber: 2, title: nil, bookmarkedAyah: 255)]
        )
    }

    func test_handleDeepLink_should_ignoreNonNumericAyah() {
        // Arrange
        let url = "hidayahapp://inAppDeeplink/quran/2/abc"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(
            router.quranPath,
            [.surahDetail(surahNumber: 2, title: nil, bookmarkedAyah: nil)]
        )
    }

    func test_handleDeepLink_should_treatNonNumericSurahAsQuranTab() {
        // Arrange
        router.quranPath = [.bookmarkList]

        // Act
        let handled = handle("hidayahapp://inAppDeeplink/quran/kahf")

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertEqual(router.quranPath, [.bookmarkList], "the current tab is left as it was")
    }

    func test_handleDeepLink_should_openBookmarkList() {
        // Arrange
        router.selectTab(.search)

        // Act
        let handled = handle("hidayahapp://inAppDeeplink/bookmark")

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertEqual(router.quranPath, [.bookmarkList])
    }

    func test_handleDeepLink_should_openTrackerTab() {
        // Arrange
        let url = "hidayahapp://inAppDeeplink/tracker"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertTrue(handled)
        XCTAssertEqual(router.selectedTab, .tracker)
    }

    func test_handleDeepLink_should_rejectUnknownHost() {
        // Arrange
        router.settingsPresented = true

        // Act
        let handled = handle("https://www.hasifofficial.com/quran")

        // Assert
        XCTAssertFalse(handled)
        XCTAssertTrue(router.settingsPresented)
        XCTAssertEqual(router.selectedTab, .quran)
    }

    func test_handleDeepLink_should_rejectMissingPath() {
        // Arrange
        let url = "hidayahapp://inAppDeeplink"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertFalse(handled)
    }

    func test_handleDeepLink_should_rejectUnknownPath() {
        // Arrange
        let url = "hidayahapp://inAppDeeplink/settings"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertFalse(handled)
    }

    func test_handleDeepLink_should_rejectURLWithoutHost() {
        // Arrange
        let url = "hidayahapp:quran"

        // Act
        let handled = handle(url)

        // Assert
        XCTAssertFalse(handled)
    }
}
