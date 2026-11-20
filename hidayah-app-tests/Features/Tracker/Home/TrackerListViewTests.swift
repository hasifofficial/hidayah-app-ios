//
//  TrackerListViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class TrackerListViewTests: XCTestCase {
    private var calendarOpened = 0
    private var achievementsOpened = 0
    private var levelsOpened = 0
    private var settingsOpened = 0

    private func makeHost(_ taskManager: TaskManager) -> ViewHost<some View> {
        let host = ViewHost(
            NavigationStack {
                TrackerListView(
                    taskManager: taskManager,
                    onOpenCalendar: { self.calendarOpened += 1 },
                    onOpenAchievements: { self.achievementsOpened += 1 },
                    onOpenLevels: { self.levelsOpened += 1 },
                    onOpenSettings: { self.settingsOpened += 1 }
                )
            }
        )
        host.pump(0.6)
        return host
    }

    func test_body_should_showSummaryAndTasksGroupedByCategory() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        taskManager.addTask(name: "Witr", category: .default(.isha))

        // Act
        let host = makeHost(taskManager)

        // Assert
        XCTAssertTrue(host.contains("Today’s Tasks"))
        XCTAssertTrue(host.contains("0/4"))
        XCTAssertTrue(host.contains("0%"))
        XCTAssertTrue(host.contains("Fajr (Dawn Prayer)"))
        XCTAssertTrue(host.contains("0 of 3 completed"))
        XCTAssertTrue(host.contains("Isha (Night Prayer)"))
        XCTAssertTrue(host.contains("0 of 1 completed"))
        XCTAssertTrue(host.contains("Recite Quran"))
        XCTAssertFalse(host.contains("Upon Waking Up"))
    }

    func test_tappingTask_should_toggleItsCompletion() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)

        // Act
        host.tap("Dhikr")
        host.pump(0.3)

        // Assert
        XCTAssertEqual(taskManager.tasks.filter(\.isCompleted).map(\.name), ["Dhikr"])
        XCTAssertTrue(host.contains("1 of 3 completed"))
        XCTAssertTrue(host.contains("33%"))
        XCTAssertTrue(host.contains("1/3"))
    }

    func test_tappingEdit_should_turnRowsIntoEditLinks() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)

        // Act
        host.tap("Edit")
        host.pump(0.3)
        host.tap("Dhikr")
        host.pump(0.8)

        // Assert
        XCTAssertTrue(host.contains("Edit Task"))
        XCTAssertTrue(host.contains("Delete Task"))
        XCTAssertFalse(taskManager.tasks.contains(where: \.isCompleted))
    }

    func test_tappingDone_should_leaveEditMode() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        host.tap("Edit")
        host.pump(0.3)

        // Act
        host.tap("Done")
        host.pump(0.3)
        host.tap("Dhikr")

        // Assert
        XCTAssertTrue(host.contains("Edit"))
        XCTAssertEqual(taskManager.tasks.filter(\.isCompleted).map(\.name), ["Dhikr"])
    }

    func test_tappingLevelTile_should_openLevels() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)

        // Act
        host.tap("Level")

        // Assert
        XCTAssertEqual(levelsOpened, 1)
    }

    func test_toolbarButtons_should_openCalendarAchievementsAndSettings() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        let labels = ["Calendar", host.trophyLabel, "More"]

        // Act
        for label in labels {
            host.tapButton(label)
        }

        // Assert
        XCTAssertEqual(calendarOpened, 1, "\(host.labels())")
        XCTAssertEqual(achievementsOpened, 1, "\(host.labels())")
        XCTAssertEqual(settingsOpened, 1, "\(host.labels())")
    }

    func test_summaryCard_should_showStreakLevelAndPoints() {
        // Arrange
        let (taskManager, clock, builder) = makeTrackerFixture(
            start: TrackerDayKey.calendar.date(byAdding: .day, value: -2, to: Date())!
        )
        builder.record([3, 3])
        XCTAssertEqual(TrackerDayKey.key(for: clock.now), TrackerDayKey.today())

        // Act
        let host = makeHost(taskManager)

        // Assert
        XCTAssertEqual(taskManager.stats.currentStreak, 2)
        XCTAssertTrue(host.contains("2, Level"), "\(host.labels())")
        XCTAssertTrue(host.contains("160"))
        XCTAssertTrue(host.contains("Streak"))
    }
}
