//
//  WidgetGuideViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class WidgetGuideViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeTask(_ name: String, done: Bool) -> TaskDetails {
        TaskDetails(name: name, category: .default(.fajr), isCompleted: done)
    }

    func test_init_should_selectTrackerWidgetAndListQuickSurahs() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()

        // Act
        let vm = WidgetGuideViewModel(taskManager: taskManager)

        // Assert
        XCTAssertEqual(vm.selectedWidget, .tracker)
        XCTAssertEqual(vm.quickSurahs.map(\.id), [18, 32, 36])
        XCTAssertEqual(vm.quickSurahs.map(\.name), ["Al-Kahf", "As-Sajda", "Yaseen"])
    }

    func test_select_should_changeSelectedWidget() {
        // Arrange
        let vm = WidgetGuideViewModel(taskManager: VMFixtures.makeTaskManager())

        // Act
        vm.select(.quickSurahs)

        // Assert
        XCTAssertEqual(vm.selectedWidget, .quickSurahs)
    }

    func test_counts_should_reflectTaskManagerTasks() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()
        taskManager.tasks = [
            makeTask("A", done: true),
            makeTask("B", done: false),
            makeTask("C", done: true),
            makeTask("D", done: false)
        ]
        let vm = WidgetGuideViewModel(taskManager: taskManager)

        // Act
        let completed = vm.completedCount
        let total = vm.totalCount
        let progress = vm.todayProgress

        // Assert
        XCTAssertEqual(completed, 2)
        XCTAssertEqual(total, 4)
        XCTAssertEqual(progress, 0.5)
    }

    func test_todayProgress_should_beZeroWithoutTasks() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()
        taskManager.tasks = []
        let vm = WidgetGuideViewModel(taskManager: taskManager)

        // Act
        let progress = vm.todayProgress

        // Assert
        XCTAssertEqual(progress, 0)
    }

    func test_upcomingTasks_should_listFirstThreeIncompleteTasks() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()
        taskManager.tasks = [
            makeTask("A", done: true),
            makeTask("B", done: false),
            makeTask("C", done: false),
            makeTask("D", done: true),
            makeTask("E", done: false),
            makeTask("F", done: false)
        ]
        let vm = WidgetGuideViewModel(taskManager: taskManager)

        // Act
        let upcoming = vm.upcomingTasks

        // Assert
        XCTAssertEqual(upcoming.map(\.name), ["B", "C", "E"])
    }

    func test_counts_should_followTaskCompletionToggle() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()
        let vm = WidgetGuideViewModel(taskManager: taskManager)
        let first = taskManager.tasks[0]

        // Act
        taskManager.toggleTaskCompletion(task: first)

        // Assert
        XCTAssertEqual(vm.completedCount, 1)
        XCTAssertEqual(vm.totalCount, taskManager.tasks.count)
        XCTAssertFalse(vm.upcomingTasks.contains { $0.id == first.id })
    }

    func test_widgetGuideKind_should_exposeKeysAndIcons() {
        // Arrange
        let kinds = WidgetGuideKind.allCases

        // Act
        let summary = kinds.map { [$0.id, $0.titleKey, $0.bodyKey, $0.icon] }

        // Assert
        XCTAssertEqual(summary, [
            ["tracker", "widget_guide_tracker_title", "widget_guide_tracker_body", "chart.pie.fill"],
            ["quickSurahs", "widget_guide_quick_title", "widget_guide_quick_body", "book.closed.fill"]
        ])
    }
}
