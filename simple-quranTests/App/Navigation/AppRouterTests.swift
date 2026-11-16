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
        // Most tests exercise the Reading stack, so start there.
        sut.selectTab(.reading)
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func test_init_should_startOnHomeWithEmptyPaths() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let router = AppRouter()

        // Assert
        XCTAssertEqual(router.selectedTab, .home)
        XCTAssertTrue(router.homePath.isEmpty)
        XCTAssertTrue(router.readingPath.isEmpty)
        XCTAssertTrue(router.searchPath.isEmpty)
        XCTAssertTrue(router.trackerPath.isEmpty)
        XCTAssertFalse(router.settingsPresented)
        XCTAssertNil(router.errorMessage)
    }

    func test_selectTab_should_ignoreCurrentTab() {
        // Arrange
        sut.readingPath = [detail]

        // Act
        sut.selectTab(.reading)

        // Assert
        XCTAssertEqual(sut.readingPath, [detail])
        XCTAssertTrue(sut.savedReadingPath.isEmpty)
    }

    func test_selectTab_should_saveAndClearPathOfPreviousTab() {
        // Arrange
        sut.readingPath = [detail]

        // Act
        sut.selectTab(.tracker)

        // Assert
        XCTAssertEqual(sut.selectedTab, .tracker)
        XCTAssertTrue(sut.readingPath.isEmpty)
        XCTAssertEqual(sut.savedReadingPath, [detail])
    }

    func test_selectTab_should_restoreSavedPathWhenReturning() {
        // Arrange
        sut.readingPath = [detail]
        sut.selectTab(.tracker)
        sut.trackerPath = [.trackerCalendar, .trackerDay(dayKey: "2026-03-10")]

        // Act
        sut.selectTab(.reading)

        // Assert
        XCTAssertEqual(sut.readingPath, [detail])
        XCTAssertTrue(sut.savedReadingPath.isEmpty)
        XCTAssertTrue(sut.trackerPath.isEmpty)
        XCTAssertEqual(sut.savedTrackerPath, [.trackerCalendar, .trackerDay(dayKey: "2026-03-10")])
    }

    func test_selectTab_should_restoreTrackerPath() {
        // Arrange
        sut.selectTab(.tracker)
        sut.trackerPath = [.trackerAchievements]
        sut.selectTab(.reading)

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
        sut.selectTab(.home)
        XCTAssertTrue(sut.searchPath.isEmpty)

        // Act
        sut.selectTab(.search)

        // Assert
        XCTAssertEqual(sut.searchPath, [detail])
        XCTAssertTrue(sut.savedSearchPath.isEmpty)
    }

    func test_selectTab_should_restoreReadingPathAfterVisitingSearch() {
        // Arrange
        sut.readingPath = [.mathurat]
        sut.selectTab(.search)

        // Act
        sut.selectTab(.reading)

        // Assert
        XCTAssertEqual(sut.readingPath, [.mathurat])
        XCTAssertTrue(sut.savedReadingPath.isEmpty)
    }

    func test_openReading_should_replaceSavedReadingPath() {
        // Arrange
        sut.readingPath = [.quranList, .bookmarkList]
        sut.selectTab(.tracker)

        // Act
        sut.openReading([.quranList, detail])

        // Assert
        XCTAssertEqual(sut.selectedTab, .reading)
        XCTAssertEqual(sut.readingPath, [.quranList, detail])
        XCTAssertTrue(sut.savedReadingPath.isEmpty)
    }

    func test_openMathurat_should_pushMathuratAndSetFocus() {
        // Arrange
        sut.selectTab(.search)

        // Act
        sut.openMathurat(focusOrder: 7)

        // Assert
        XCTAssertEqual(sut.selectedTab, .reading)
        XCTAssertEqual(sut.readingPath, [.mathurat])
        XCTAssertEqual(sut.mathuratFocusOrder, 7)
    }

    func test_selectTab_should_saveAndRestoreHomePath() {
        // Arrange
        sut.selectTab(.home)
        sut.homePath = [.mathurat]
        sut.selectTab(.tracker)
        let savedWhileAway = sut.savedHomePath

        // Act
        sut.selectTab(.home)

        // Assert
        XCTAssertEqual(savedWhileAway, [.mathurat])
        XCTAssertEqual(sut.homePath, [.mathurat])
        XCTAssertTrue(sut.savedHomePath.isEmpty)
    }

    func test_push_should_appendToSelectedTabStack() {
        // Arrange
        var pushed: [AppTab: [AppRoute]] = [:]

        // Act
        for tab in AppTab.allCases {
            sut.selectTab(tab, clearingPaths: false)
            sut.push(.bookmarkList)
        }
        pushed[.home] = sut.homePath
        pushed[.reading] = sut.readingPath
        pushed[.tracker] = sut.trackerPath
        pushed[.search] = sut.searchPath

        // Assert
        XCTAssertEqual(pushed[.home], [.bookmarkList])
        XCTAssertEqual(pushed[.reading], [.bookmarkList])
        XCTAssertEqual(pushed[.tracker], [.bookmarkList])
        XCTAssertEqual(pushed[.search], [.bookmarkList])
    }

    func test_selectTab_should_keepPathsWhenNotClearing() {
        // Arrange
        sut.readingPath = [detail]
        sut.trackerPath = [.trackerLevels]

        // Act
        sut.selectTab(.tracker, clearingPaths: false)

        // Assert
        XCTAssertEqual(sut.selectedTab, .tracker)
        XCTAssertEqual(sut.readingPath, [detail])
        XCTAssertEqual(sut.trackerPath, [.trackerLevels])
        XCTAssertTrue(sut.savedReadingPath.isEmpty)
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
