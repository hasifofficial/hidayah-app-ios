//
//  TrackerViewFixtures.swift
//  simple-quranTests
//

import Foundation
@testable import simple_quran

/// Builds tracker history through the real rollover path: for each day,
/// completes `completed` of the manager's tasks, then moves the clock to the
/// next day so the day is archived.
@MainActor
struct TrackerHistoryBuilder {
    let taskManager: TaskManager
    let clock: TestClock

    /// Replaces the default task list with `names` in one category, through
    /// the manager's own API so the store matches, and days can be
    /// completed quickly.
    func useTasks(_ names: [String], category: simple_quran.Category = .default(.fajr)) {
        for task in taskManager.tasks {
            taskManager.deleteTask(task: task)
        }
        for name in names {
            taskManager.addTask(name: name, category: category)
        }
    }

    func complete(_ completed: Int) {
        for task in taskManager.tasks.prefix(completed) {
            taskManager.toggleTaskCompletion(task: task)
        }
    }

    func finishDay() {
        clock.advance(days: 1)
        taskManager.refreshForCurrentDay()
    }

    /// Records one day per entry in `completedPerDay`, starting today.
    func record(_ completedPerDay: [Int]) {
        for completed in completedPerDay {
            complete(completed)
            finishDay()
        }
    }
}

@MainActor
func makeTrackerFixture(
    start: Date = TestClock.date(year: 2026, month: 10, day: 1),
    tasks: [String] = ["Fajr prayer", "Dhikr", "Recite Quran"]
) -> (TaskManager, TestClock, TrackerHistoryBuilder) {
    resetStorage()
    let clock = TestClock(start)
    let taskManager = makeTrackerTaskManager(clock: clock)
    let builder = TrackerHistoryBuilder(taskManager: taskManager, clock: clock)
    builder.useTasks(tasks)
    return (taskManager, clock, builder)
}
