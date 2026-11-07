//
//  TrackerProviderTests.swift
//  app-widgetTests
//

import WidgetKit
import XCTest

@MainActor
final class TrackerProviderTests: XCTestCase {
    private let now = trackerDate(year: 2026, month: 11, day: 3, hour: 9, minute: 30)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    override func tearDown() {
        resetStorage()
        super.tearDown()
    }

    private func makeContext(
        dayKey: String?,
        upcoming: [TaskDetails] = [makeTask("Fajr prayer")],
        reset: [TaskDetails]? = [makeTask("Dawn Alms"), makeTask("Fajr prayer")]
    ) -> WidgetContext {
        WidgetContext(
            progress: 0.5,
            completedTasks: 1,
            totalTasks: 2,
            upcomingTasks: upcoming,
            dayKey: dayKey,
            resetUpcomingTasks: reset
        )
    }

    // MARK: - Entries

    func test_entry_should_showTodaysSnapshotAsIs() {
        // Arrange
        let context = makeContext(dayKey: TrackerDayKey.key(for: now))

        // Act
        let entry = TrackerProvider.entry(for: context, on: now)

        // Assert
        XCTAssertEqual(entry.date, now)
        XCTAssertEqual(entry.progress, 0.5)
        XCTAssertEqual(entry.completedTasks, 1)
        XCTAssertEqual(entry.totalTasks, 2)
        XCTAssertEqual(entry.upcomingTasks.map(\.name), ["Fajr prayer"])
    }

    func test_entry_should_resetSnapshotFromEarlierDay() {
        // Arrange
        let context = makeContext(dayKey: "2026-11-02")

        // Act
        let entry = TrackerProvider.entry(for: context, on: now)

        // Assert
        XCTAssertEqual(entry.progress, 0)
        XCTAssertEqual(entry.completedTasks, 0)
        XCTAssertEqual(entry.totalTasks, 2)
        XCTAssertEqual(entry.upcomingTasks.map(\.name), ["Dawn Alms", "Fajr prayer"])
    }

    func test_entry_should_showNoUpcomingTasks_when_earlierSnapshotHasNoResetList() {
        // Arrange
        let context = makeContext(dayKey: "2026-11-02", reset: nil)

        // Act
        let entry = TrackerProvider.entry(for: context, on: now)

        // Assert
        XCTAssertEqual(entry.completedTasks, 0)
        XCTAssertEqual(entry.totalTasks, 2)
        XCTAssertTrue(entry.upcomingTasks.isEmpty)
    }

    func test_entry_should_useDefaults_when_snapshotIsMissing() {
        // Arrange
        let context: WidgetContext? = nil

        // Act
        let entry = TrackerProvider.entry(for: context, on: now)

        // Assert
        XCTAssertEqual(entry.progress, 0)
        XCTAssertEqual(entry.completedTasks, 0)
        XCTAssertEqual(entry.totalTasks, 1)
        XCTAssertTrue(entry.upcomingTasks.isEmpty)
    }

    func test_entry_should_showLegacySnapshotAsIs_when_dayKeyIsMissing() {
        // Arrange
        let context = makeContext(dayKey: nil)
        let muchLater = trackerDate(year: 2027, month: 1, day: 1)

        // Act
        let entry = TrackerProvider.entry(for: context, on: muchLater)

        // Assert
        XCTAssertEqual(entry.progress, 0.5)
        XCTAssertEqual(entry.completedTasks, 1)
        XCTAssertEqual(entry.upcomingTasks.map(\.name), ["Fajr prayer"])
    }

    // MARK: - Timeline

    func test_timeline_should_appendResetEntryAtNextMidnight() {
        // Arrange
        let context = makeContext(dayKey: TrackerDayKey.key(for: now))
        let midnight = trackerDate(year: 2026, month: 11, day: 4, hour: 0)

        // Act
        let timeline = TrackerProvider.timeline(for: context, now: now)

        // Assert
        XCTAssertEqual(timeline.entries.map(\.date), [now, midnight])
        XCTAssertEqual(timeline.entries[0].completedTasks, 1)
        XCTAssertEqual(timeline.entries[0].upcomingTasks.map(\.name), ["Fajr prayer"])
        XCTAssertEqual(timeline.entries[1].completedTasks, 0)
        XCTAssertEqual(timeline.entries[1].progress, 0)
        XCTAssertEqual(timeline.entries[1].upcomingTasks.map(\.name), ["Dawn Alms", "Fajr prayer"])
    }

    func test_timeline_should_appendResetEntryAtChosenResetTime() {
        // Arrange
        TrackerDayKey.dayStartMinutes = 4 * 60
        let context = makeContext(dayKey: TrackerDayKey.today(now: now))
        let resetTime = trackerDate(year: 2026, month: 11, day: 4, hour: 4)

        // Act
        let timeline = TrackerProvider.timeline(for: context, now: now)

        // Assert
        XCTAssertEqual(timeline.entries.map(\.date), [now, resetTime])
        XCTAssertEqual(timeline.entries[0].completedTasks, 1)
        XCTAssertEqual(timeline.entries[1].completedTasks, 0)
    }

    func test_entry_should_keepSnapshot_when_beforeResetTimeAfterMidnight() {
        // Arrange
        TrackerDayKey.dayStartMinutes = 4 * 60
        let context = makeContext(dayKey: "2026-11-03")
        let twoAM = trackerDate(year: 2026, month: 11, day: 4, hour: 2)

        // Act
        let entry = TrackerProvider.entry(for: context, on: twoAM)

        // Assert
        XCTAssertEqual(entry.completedTasks, 1)
    }

    func test_timeline_should_refreshAfterFifteenMinutes() {
        // Arrange
        let context = makeContext(dayKey: TrackerDayKey.key(for: now))

        // Act
        let timeline = TrackerProvider.timeline(for: context, now: now)

        // Assert
        XCTAssertEqual(timeline.policy, .after(now.addingTimeInterval(15 * 60)))
    }

    func test_timeline_should_showDefaultsInBothEntries_when_snapshotIsMissing() {
        // Arrange
        let context: WidgetContext? = nil

        // Act
        let timeline = TrackerProvider.timeline(for: context, now: now)

        // Assert
        XCTAssertEqual(timeline.entries.count, 2)
        XCTAssertEqual(timeline.entries.map(\.totalTasks), [1, 1])
        XCTAssertEqual(timeline.entries.map(\.completedTasks), [0, 0])
    }

    // MARK: - Sample

    func test_sampleEntry_should_describeGallerySample() {
        // Arrange
        let date = now

        // Act
        let entry = TrackerProvider.sampleEntry(date: date)

        // Assert
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.progress, 0.65)
        XCTAssertEqual(entry.completedTasks, 15)
        XCTAssertEqual(entry.totalTasks, 23)
        XCTAssertEqual(entry.upcomingTasks.count, 10)
        XCTAssertEqual(entry.upcomingTasks.first?.name, "Dawn Alms (Sodaqah)")
        XCTAssertTrue(entry.upcomingTasks.allSatisfy { !$0.isCompleted })
    }

    // MARK: - Protocol methods
}
