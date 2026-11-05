//
//  AppRouterTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class AppRouterTests: XCTestCase {
    private var sut: AppRouter!

    private let detail = AppRoute.surahDetail(surahNumber: 18, title: "Al-Kahf", bookmarkedAyah: nil)

    override func setUp() async throws {
        try await super.setUp()
        sut = AppRouter()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func test_init_should_startOnQuranWithEmptyPaths() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let router = AppRouter()

        // Assert
        XCTAssertEqual(router.selectedTab, .quran)
        XCTAssertTrue(router.quranPath.isEmpty)
        XCTAssertTrue(router.searchPath.isEmpty)
        XCTAssertTrue(router.trackerPath.isEmpty)
        XCTAssertFalse(router.settingsPresented)
        XCTAssertNil(router.errorMessage)
    }

    func test_selectTab_should_ignoreCurrentTab() {
        // Arrange
        sut.quranPath = [detail]

        // Act
        sut.selectTab(.quran)

        // Assert
        XCTAssertEqual(sut.quranPath, [detail])
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
    }

    func test_selectTab_should_saveAndClearPathOfPreviousTab() {
        // Arrange
        sut.quranPath = [detail]

        // Act
        sut.selectTab(.tracker)

        // Assert
        XCTAssertEqual(sut.selectedTab, .tracker)
        XCTAssertTrue(sut.quranPath.isEmpty)
        XCTAssertEqual(sut.savedQuranPath, [detail])
    }

    func test_selectTab_should_restoreSavedPathWhenReturning() {
        // Arrange
        sut.quranPath = [detail]
        sut.selectTab(.tracker)
        sut.trackerPath = [.trackerCalendar, .trackerDay(dayKey: "2026-03-10")]

        // Act
        sut.selectTab(.quran)

        // Assert
        XCTAssertEqual(sut.quranPath, [detail])
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
        XCTAssertTrue(sut.trackerPath.isEmpty)
        XCTAssertEqual(sut.savedTrackerPath, [.trackerCalendar, .trackerDay(dayKey: "2026-03-10")])
    }

    func test_selectTab_should_restoreTrackerPath() {
        // Arrange
        sut.selectTab(.tracker)
        sut.trackerPath = [.trackerAchievements]
        sut.selectTab(.quran)

        // Act
        sut.selectTab(.tracker)

        // Assert
        XCTAssertEqual(sut.trackerPath, [.trackerAchievements])
        XCTAssertTrue(sut.savedTrackerPath.isEmpty)
    }

    func test_selectTab_should_saveAndRestoreSearchPath() {
        // Arrange
        sut.selectTab(.search)
        sut.searchPath = [detail]
        sut.selectTab(.tasbih)
        XCTAssertTrue(sut.searchPath.isEmpty)

        // Act
        sut.selectTab(.search)

        // Assert
        XCTAssertEqual(sut.searchPath, [detail])
        XCTAssertTrue(sut.savedSearchPath.isEmpty)
    }

    func test_selectTab_should_leaveTasbihWithoutSavingAnything() {
        // Arrange
        sut.selectTab(.tasbih)
        sut.quranPath = [.bookmarkList]

        // Act
        sut.selectTab(.tracker)

        // Assert
        XCTAssertEqual(sut.selectedTab, .tracker)
        XCTAssertTrue(sut.quranPath.isEmpty)
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
    }

    func test_selectTab_should_leaveMathuratWithoutSavingAnything() {
        // Arrange
        sut.selectTab(.mathurat)
        sut.quranPath = [.bookmarkList]

        // Act
        sut.selectTab(.search)

        // Assert
        XCTAssertEqual(sut.selectedTab, .search)
        XCTAssertTrue(sut.quranPath.isEmpty)
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
        XCTAssertTrue(sut.savedSearchPath.isEmpty)
    }

    func test_selectTab_should_restoreQuranPathAfterVisitingMathurat() {
        // Arrange
        sut.quranPath = [.bookmarkList]
        sut.selectTab(.mathurat)

        // Act
        sut.selectTab(.quran)

        // Assert
        XCTAssertEqual(sut.quranPath, [.bookmarkList])
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
    }

    func test_selectTab_should_keepPathsWhenNotClearing() {
        // Arrange
        sut.quranPath = [detail]
        sut.trackerPath = [.trackerLevels]

        // Act
        sut.selectTab(.tracker, clearingPaths: false)

        // Assert
        XCTAssertEqual(sut.selectedTab, .tracker)
        XCTAssertEqual(sut.quranPath, [detail])
        XCTAssertEqual(sut.trackerPath, [.trackerLevels])
        XCTAssertTrue(sut.savedQuranPath.isEmpty)
    }

    func test_settingsRoute_should_distinguishCases() {
        // Arrange
        let routes: Set<SettingsRoute> = [.trackerSettings, .manageCategories, .widgetGuide]

        // Act
        let count = routes.count

        // Assert
        XCTAssertEqual(count, 3)
    }
}
