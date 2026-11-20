//
//  TrackerStatsTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerStatsTests: XCTestCase {
    private let now = TestClock.date(year: 2026, month: 3, day: 10)

    func test_stats_should_beEmptyWithoutRecords() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let stats = TrackerStats(records: [], now: now)

        // Assert
        XCTAssertEqual(stats.totalPoints, 0)
        XCTAssertEqual(stats.level, 1)
        XCTAssertEqual(stats.levelStartPoints, 0)
        XCTAssertEqual(stats.nextLevelPoints, 100)
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertEqual(stats.longestStreak, 0)
        XCTAssertEqual(stats.perfectDays, 0)
        XCTAssertTrue(stats.unlockedBadges.isEmpty)
        XCTAssertEqual(stats.progressToNextLevel, 0)
    }

    func test_stats_should_sumPointsAndCompletedTasks() {
        // Arrange
        let records = [
            makeRecord("2026-03-08", completed: 2, total: 2),
            makeRecord("2026-03-09", completed: 1, total: 3)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.totalPoints, 80)
        XCTAssertEqual(stats.totalCompletedTasks, 3)
        XCTAssertEqual(stats.perfectDays, 1)
        XCTAssertEqual(stats.unlockedBadges, [.firstStep, .perfectDay])
    }

    func test_stats_should_keepLastRecordForDuplicateDay() {
        // Arrange
        let records = [
            makeRecord("2026-03-10", completed: 1, total: 2),
            makeRecord("2026-03-10", completed: 2, total: 2)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.totalPoints, 70)
    }

    func test_stats_should_countCurrentStreakEndingToday() {
        // Arrange
        let records = [
            makeRecord("2026-03-07", completed: 1, total: 1),
            makeRecord("2026-03-08", completed: 1, total: 1),
            makeRecord("2026-03-09", completed: 1, total: 1),
            makeRecord("2026-03-10", completed: 1, total: 1)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.currentStreak, 4)
        XCTAssertEqual(stats.longestStreak, 4)
        XCTAssertTrue(stats.unlockedBadges.contains(.streak3))
        XCTAssertFalse(stats.unlockedBadges.contains(.streak7))
    }

    func test_stats_should_countCurrentStreakEndingYesterday() {
        // Arrange
        let records = [
            makeRecord("2026-03-08", completed: 1, total: 1),
            makeRecord("2026-03-09", completed: 1, total: 1)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.currentStreak, 2)
    }

    func test_stats_should_resetCurrentStreakAfterMissedDay() {
        // Arrange
        let records = [
            makeRecord("2026-03-01", completed: 1, total: 1),
            makeRecord("2026-03-02", completed: 1, total: 1),
            makeRecord("2026-03-03", completed: 1, total: 1),
            makeRecord("2026-03-08", completed: 1, total: 1)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertEqual(stats.longestStreak, 3)
    }

    func test_stats_should_ignoreDaysWithoutCompletedTasksInStreaks() {
        // Arrange
        let records = [
            makeRecord("2026-03-08", completed: 1, total: 1),
            makeRecord("2026-03-09", completed: 0, total: 1),
            makeRecord("2026-03-10", completed: 1, total: 1)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.currentStreak, 1)
        XCTAssertEqual(stats.longestStreak, 1)
    }

    func test_stats_should_skipMalformedDayKeysInLongestStreak() {
        // Arrange
        let records = [
            makeRecord("bad", completed: 1, total: 1),
            makeRecord("2026-03-09", completed: 1, total: 1),
            makeRecord("2026-03-10", completed: 1, total: 1)
        ]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.longestStreak, 2)
    }

    func test_stats_should_unlockStreakAndVolumeBadges() {
        // Arrange
        let start = TestClock.date(year: 2026, month: 1, day: 1)
        let records = (0..<30).map { offset -> TrackerDayRecord in
            let date = TrackerDayKey.calendar.date(byAdding: .day, value: offset, to: start)!
            return makeRecord(TrackerDayKey.key(for: date), completed: 4, total: 4)
        }
        let lastDay = TrackerDayKey.calendar.date(byAdding: .day, value: 29, to: start)!

        // Act
        let stats = TrackerStats(records: records, now: lastDay)

        // Assert
        XCTAssertEqual(stats.currentStreak, 30)
        XCTAssertEqual(stats.perfectDays, 30)
        XCTAssertEqual(stats.totalCompletedTasks, 120)
        XCTAssertEqual(
            stats.unlockedBadges,
            [.firstStep, .streak3, .streak7, .streak30, .perfectDay, .perfectTen, .century]
        )
    }

    func test_stats_should_unlockDevotedBadgeAtOneThousandTasks() {
        // Arrange
        let records = [TrackerDayRecord(dayKey: "2026-03-10", completedCount: 1_000, totalCount: 1_000, points: 0)]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertTrue(stats.unlockedBadges.contains(.devoted))
        XCTAssertEqual(stats.progress(for: .devoted), 1)
    }

    func test_stats_should_pickLevelFromThresholds() {
        // Arrange
        let records = [TrackerDayRecord(dayKey: "2026-03-10", completedCount: 1, totalCount: 1, points: 300)]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.level, 3)
        XCTAssertEqual(stats.levelStartPoints, 250)
        XCTAssertEqual(stats.nextLevelPoints, 500)
        XCTAssertEqual(stats.progressToNextLevel, 0.2, accuracy: 0.0001)
    }

    func test_stats_should_capProgressAtTopLevel() {
        // Arrange
        let records = [TrackerDayRecord(dayKey: "2026-03-10", completedCount: 1, totalCount: 1, points: 9_999)]

        // Act
        let stats = TrackerStats(records: records, now: now)

        // Assert
        XCTAssertEqual(stats.level, TrackerStats.levelThresholds.count)
        XCTAssertNil(stats.nextLevelPoints)
        XCTAssertEqual(stats.progressToNextLevel, 1)
    }

    func test_progressForBadge_should_measureAgainstTarget() {
        // Arrange
        let records = [
            makeRecord("2026-03-09", completed: 3, total: 3),
            makeRecord("2026-03-10", completed: 2, total: 4)
        ]
        let stats = TrackerStats(records: records, now: now)

        // Act
        let firstStep = stats.progress(for: .firstStep)
        let century = stats.progress(for: .century)
        let streak7 = stats.progress(for: .streak7)
        let perfectTen = stats.progress(for: .perfectTen)

        // Assert
        XCTAssertEqual(firstStep, 1)
        XCTAssertEqual(century, 0.05, accuracy: 0.0001)
        XCTAssertEqual(streak7, 2.0 / 7.0, accuracy: 0.0001)
        XCTAssertEqual(perfectTen, 0.1, accuracy: 0.0001)
    }

    func test_badgeCurrentValue_should_returnMatchingStat() {
        // Arrange
        let records = [
            makeRecord("2026-03-09", completed: 3, total: 3),
            makeRecord("2026-03-10", completed: 2, total: 4)
        ]
        let stats = TrackerStats(records: records, now: now)

        // Act
        let tasks = stats.badgeCurrentValue(.century)
        let streak = stats.badgeCurrentValue(.streak3)
        let perfect = stats.badgeCurrentValue(.perfectDay)

        // Assert
        XCTAssertEqual(tasks, 5)
        XCTAssertEqual(streak, 2)
        XCTAssertEqual(perfect, 1)
    }
}
