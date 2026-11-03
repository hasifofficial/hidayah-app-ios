//
//  TrackerHistoryEngineTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerHistoryEngineTests: XCTestCase {
    private let sut = TrackerHistoryEngine()

    func test_init_should_defaultToTrackerCalendar() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let engine = TrackerHistoryEngine()

        // Assert
        XCTAssertEqual(engine.calendar.identifier, .gregorian)
    }

    func test_makeRecord_should_returnNilWhenNothingIsCompleted() {
        // Arrange
        let tasks = [makeTask("A"), makeTask("B")]

        // Act
        let record = sut.makeRecord(for: tasks, on: "2026-03-10")

        // Assert
        XCTAssertNil(record)
    }

    func test_makeRecord_should_snapshotTasksWhenSomethingIsCompleted() {
        // Arrange
        let tasks = [makeTask("A", isCompleted: true), makeTask("B")]

        // Act
        let record = sut.makeRecord(for: tasks, on: "2026-03-10")

        // Assert
        XCTAssertEqual(record?.dayKey, "2026-03-10")
        XCTAssertEqual(record?.tasks.map(\.id), tasks.map(\.id))
        XCTAssertEqual(record?.completedCount, 1)
        XCTAssertEqual(record?.totalCount, 2)
    }

    func test_upsert_should_insertRecordsSortedByDay() {
        // Arrange
        var history = [makeRecord("2026-03-12", completed: 1, total: 1)]

        // Act
        sut.upsert(makeRecord("2026-03-10", completed: 1, total: 1), for: "2026-03-10", in: &history)

        // Assert
        XCTAssertEqual(history.map(\.dayKey), ["2026-03-10", "2026-03-12"])
    }

    func test_upsert_should_replaceRecordForSameDay() {
        // Arrange
        var history = [makeRecord("2026-03-10", completed: 1, total: 2)]

        // Act
        sut.upsert(makeRecord("2026-03-10", completed: 2, total: 2), for: "2026-03-10", in: &history)

        // Assert
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.completedCount, 2)
    }

    func test_upsert_should_removeRecordWhenNil() {
        // Arrange
        var history = [makeRecord("2026-03-10", completed: 1, total: 2)]

        // Act
        sut.upsert(nil, for: "2026-03-10", in: &history)

        // Assert
        XCTAssertTrue(history.isEmpty)
    }

    func test_rollover_should_archiveActiveDayAndResetTasks() {
        // Arrange
        var tasks = [makeTask("A", isCompleted: true), makeTask("B")]
        var history: [TrackerDayRecord] = []
        let now = TestClock.date(year: 2026, month: 3, day: 11)

        // Act
        let key = sut.rollover(activeDayKey: "2026-03-10", tasks: &tasks, history: &history, now: now)

        // Assert
        XCTAssertEqual(key, "2026-03-11")
        XCTAssertEqual(history.map(\.dayKey), ["2026-03-10"])
        XCTAssertTrue(tasks.allSatisfy { !$0.isCompleted })
    }

    func test_rollover_should_notArchiveDayWithoutCompletedTasks() {
        // Arrange
        var tasks = [makeTask("A")]
        var history: [TrackerDayRecord] = []
        let now = TestClock.date(year: 2026, month: 3, day: 11)

        // Act
        let key = sut.rollover(activeDayKey: "2026-03-10", tasks: &tasks, history: &history, now: now)

        // Assert
        XCTAssertEqual(key, "2026-03-11")
        XCTAssertTrue(history.isEmpty)
    }

    func test_rollover_should_leaveTasksAloneOnSameDay() {
        // Arrange
        var tasks = [makeTask("A", isCompleted: true)]
        var history: [TrackerDayRecord] = []
        let now = TestClock.date(year: 2026, month: 3, day: 10)

        // Act
        let key = sut.rollover(activeDayKey: "2026-03-10", tasks: &tasks, history: &history, now: now)

        // Assert
        XCTAssertEqual(key, "2026-03-10")
        XCTAssertTrue(tasks[0].isCompleted)
        XCTAssertTrue(history.isEmpty)
    }

    func test_rollover_should_returnTodayWhenNoActiveDay() {
        // Arrange
        var tasks = [makeTask("A", isCompleted: true)]
        var history: [TrackerDayRecord] = []
        let now = TestClock.date(year: 2026, month: 3, day: 10)

        // Act
        let key = sut.rollover(activeDayKey: nil, tasks: &tasks, history: &history, now: now)

        // Assert
        XCTAssertEqual(key, "2026-03-10")
        XCTAssertTrue(tasks[0].isCompleted)
    }

    func test_stats_should_summariseHistory() {
        // Arrange
        let history = [makeRecord("2026-03-10", completed: 2, total: 2)]
        let now = TestClock.date(year: 2026, month: 3, day: 10)

        // Act
        let stats = sut.stats(for: history, now: now)

        // Assert
        XCTAssertEqual(stats.totalPoints, 70)
        XCTAssertEqual(stats.currentStreak, 1)
    }
}
