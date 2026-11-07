//
//  TrackerDayRecordTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerDayRecordTests: XCTestCase {
    func test_dayRecord_should_deriveCountsAndPointsFromTasks() {
        // Arrange
        let tasks = [makeTask("A", isCompleted: true), makeTask("B", isCompleted: true)]
            .map(TrackerTaskSnapshot.init(task:))

        // Act
        let record = TrackerDayRecord(dayKey: "2026-03-10", tasks: tasks)

        // Assert
        XCTAssertEqual(record.id, "2026-03-10")
        XCTAssertEqual(record.completedCount, 2)
        XCTAssertEqual(record.totalCount, 2)
        XCTAssertEqual(record.points, 70)
        XCTAssertEqual(record.progress, 1)
        XCTAssertTrue(record.isPerfectDay)
    }

    func test_dayRecord_should_reportZeroProgressWithoutTasks() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let record = TrackerDayRecord(dayKey: "2026-03-10", tasks: [])

        // Assert
        XCTAssertEqual(record.progress, 0)
        XCTAssertFalse(record.isPerfectDay)
        XCTAssertEqual(record.points, 0)
    }

    func test_dayRecord_should_roundTripThroughJSON() throws {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 1, total: 3)

        // Act
        let decoded = try JSONDecoder().decode(
            TrackerDayRecord.self,
            from: JSONEncoder().encode(record)
        )

        // Assert
        XCTAssertEqual(decoded, record)
        XCTAssertEqual(decoded.progress, 1.0 / 3.0, accuracy: 0.0001)
    }

    func test_taskSnapshot_should_copyTaskAndCategory() {
        // Arrange
        let category = CustomCategory(name: "Charity", icon: "heart")
        let task = makeTask("Give", category: .custom(category), isCompleted: true)

        // Act
        let snapshot = TrackerTaskSnapshot(task: task)

        // Assert
        XCTAssertEqual(snapshot.id, task.id)
        XCTAssertEqual(snapshot.name, "Give")
        XCTAssertEqual(snapshot.categoryID, "custom_\(category.id.uuidString)")
        XCTAssertEqual(snapshot.categoryName, "Charity")
        XCTAssertEqual(snapshot.categoryIcon, "heart")
        XCTAssertTrue(snapshot.isCompleted)
    }

    func test_scoring_should_addBonusOnlyForPerfectDay() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let none = TrackerScoring.points(completedCount: 0, totalCount: 3)
        let partial = TrackerScoring.points(completedCount: 2, totalCount: 3)
        let perfect = TrackerScoring.points(completedCount: 3, totalCount: 3)

        // Assert
        XCTAssertEqual(none, 0)
        XCTAssertEqual(partial, 20)
        XCTAssertEqual(perfect, 80)
    }

    func test_dayKeyDate_should_returnNilForNonNumericKey() {
        // Arrange
        let key = "2026-xx-10"

        // Act
        let date = TrackerDayKey.date(from: key)

        // Assert
        XCTAssertNil(date)
    }
}

final class TrackerDayKeyTests: XCTestCase {
    func test_key_should_formatDateAsYearMonthDay() {
        // Arrange
        let date = TestClock.date(year: 2026, month: 3, day: 7)

        // Act
        let key = TrackerDayKey.key(for: date)

        // Assert
        XCTAssertEqual(key, "2026-03-07")
    }

    func test_date_should_roundTripKey() {
        // Arrange
        let key = "2026-11-03"

        // Act
        let date = TrackerDayKey.date(from: key)

        // Assert
        XCTAssertEqual(date.map { TrackerDayKey.key(for: $0) }, key)
    }

    func test_date_should_returnNilForMalformedKey() {
        // Arrange
        let key = "2026-11"

        // Act
        let date = TrackerDayKey.date(from: key)

        // Assert
        XCTAssertNil(date)
    }

    func test_today_should_useInjectedNow() {
        // Arrange
        let now = TestClock.date(year: 2025, month: 12, day: 31)

        // Act
        let key = TrackerDayKey.today(now: now)

        // Assert
        XCTAssertEqual(key, "2025-12-31")
    }

    // MARK: - Reset time

    func test_today_should_stayOnPreviousDay_when_beforeResetTime() {
        // Arrange
        let twoAM = TestClock.date(year: 2026, month: 11, day: 7, hour: 2)

        // Act
        let key = TrackerDayKey.today(now: twoAM, dayStartMinutes: 4 * 60)

        // Assert
        XCTAssertEqual(key, "2026-11-06")
    }

    func test_today_should_moveToNewDay_when_afterResetTime() {
        // Arrange
        let fiveAM = TestClock.date(year: 2026, month: 11, day: 7, hour: 5)

        // Act
        let key = TrackerDayKey.today(now: fiveAM, dayStartMinutes: 4 * 60)

        // Assert
        XCTAssertEqual(key, "2026-11-07")
    }

    func test_today_should_useMidnight_byDefault() {
        // Arrange
        resetStorage()
        let oneAM = TestClock.date(year: 2026, month: 11, day: 7, hour: 1)

        // Act
        let key = TrackerDayKey.today(now: oneAM)

        // Assert
        XCTAssertEqual(TrackerDayKey.dayStartMinutes, 0)
        XCTAssertEqual(key, "2026-11-07")
    }

    func test_nextDayStart_should_beTheComingResetTime() {
        // Arrange
        let twoAM = TestClock.date(year: 2026, month: 11, day: 7, hour: 2)
        let fiveAM = TestClock.date(year: 2026, month: 11, day: 7, hour: 5)

        // Act
        let fromTwo = TrackerDayKey.nextDayStart(after: twoAM, dayStartMinutes: 4 * 60)
        let fromFive = TrackerDayKey.nextDayStart(after: fiveAM, dayStartMinutes: 4 * 60)

        // Assert
        XCTAssertEqual(fromTwo, TestClock.date(year: 2026, month: 11, day: 7, hour: 4))
        XCTAssertEqual(fromFive, TestClock.date(year: 2026, month: 11, day: 8, hour: 4))
    }

    func test_dayStartMinutes_should_ignoreUnsupportedValues() {
        // Arrange
        resetStorage()
        Storage.save(.trackerDayStartMinutes, 13 * 60)

        // Act
        let minutes = TrackerDayKey.dayStartMinutes

        // Assert
        XCTAssertEqual(minutes, 0)
        resetStorage()
    }

    func test_key_should_ignoreResetTime_forCalendarDates() {
        // Arrange
        resetStorage()
        TrackerDayKey.dayStartMinutes = 4 * 60
        let midnight = TestClock.date(year: 2026, month: 11, day: 7, hour: 0)

        // Act
        let key = TrackerDayKey.key(for: midnight)

        // Assert
        XCTAssertEqual(key, "2026-11-07")
        resetStorage()
    }
}
