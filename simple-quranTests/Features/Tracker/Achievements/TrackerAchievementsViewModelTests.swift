//
//  TrackerAchievementsViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TrackerAchievementsViewModelTests: XCTestCase {
    private var store: HidayahStore!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        store = makeInMemoryStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    /// 80 + 10 + 70 = 160 points: level 2, with First Step and Perfect Day.
    private func makeSeededTaskManager() -> TaskManager {
        store.saveDay(VMFixtures.dayRecord("2026-10-05", completed: 3, total: 3))
        store.saveDay(VMFixtures.dayRecord("2026-10-06", completed: 1, total: 4))
        store.saveDay(VMFixtures.dayRecord("2026-10-20", completed: 2, total: 2))
        return VMFixtures.makeTaskManager(store: store)
    }

    func test_stats_should_reflectSeededHistory() {
        // Arrange
        let vm = TrackerAchievementsViewModel(taskManager: makeSeededTaskManager())

        // Act
        let stats = vm.stats

        // Assert
        XCTAssertEqual(stats.totalPoints, 160)
        XCTAssertEqual(stats.level, 2)
        XCTAssertEqual(stats.perfectDays, 2)
        XCTAssertEqual(stats.longestStreak, 2)
        XCTAssertEqual(stats.unlockedBadges, [.firstStep, .perfectDay])
    }

    func test_shareSummary_should_includeLevelPointsBadgesAndFooter() {
        // Arrange
        let vm = TrackerAchievementsViewModel(taskManager: makeSeededTaskManager())

        // Act
        let summary = vm.shareSummary

        // Assert
        XCTAssertTrue(summary.contains("Level 2 in Hidayah with 160 points and 2 of 8 badges unlocked"), summary)
        XCTAssertTrue(summary.hasSuffix("\n\nShared from Hidayah App"), summary)
    }

    func test_shareSummary_should_reportLevelOneForNewTracker() {
        // Arrange
        let vm = TrackerAchievementsViewModel(taskManager: VMFixtures.makeTaskManager(store: store))

        // Act
        let summary = vm.shareSummary

        // Assert
        XCTAssertTrue(summary.contains("Level 1 in Hidayah with 0 points and 0 of 8 badges"), summary)
    }

    func test_shareText_should_includeBadgeTitleDetailAndFooter() {
        // Arrange
        let vm = TrackerAchievementsViewModel(taskManager: VMFixtures.makeTaskManager(store: store))
        let badge = TrackerBadge.streak7

        // Act
        let text = vm.shareText(for: badge)

        // Assert
        XCTAssertTrue(text.contains("\"\(badge.title)\" badge in Hidayah — \(badge.detail)."), text)
        XCTAssertTrue(text.hasSuffix("\n\nShared from Hidayah App"), text)
        XCTAssertFalse(badge.title.hasPrefix("tracker_badge_"))
    }
}
