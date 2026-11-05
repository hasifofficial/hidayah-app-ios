//
//  EditTaskViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class EditTaskViewTests: XCTestCase {
    private func makeHost(
        _ taskManager: TaskManager,
        task: TaskDetails
    ) -> ViewHost<some View> {

        let host = ViewHost(
            NavigationStack {
                EditTaskView(task: task)
                    .environment(taskManager)
            }
        )
        host.pump(0.5)
        return host
    }

    func test_body_should_showTheTaskDetails() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = makeHost(taskManager, task: taskManager.tasks[0])

        // Assert
        XCTAssertTrue(host.contains("Edit Task"))
        XCTAssertTrue(host.contains("Task Details"))
        XCTAssertTrue(host.contains("Fajr (Dawn Prayer)"))
        XCTAssertEqual(host.textFields().first?.text, "Fajr prayer")
    }

    func test_save_should_renameTheTask() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let task = taskManager.tasks[0]
        let host = makeHost(taskManager, task: task)

        // Act
        host.type("Fajr in congregation")
        host.tapButton("Save")

        // Assert
        XCTAssertEqual(taskManager.tasks.first { $0.id == task.id }?.name, "Fajr in congregation")
        XCTAssertEqual(taskManager.tasks.first { $0.id == task.id }?.category.id, task.category.id)
    }

    func test_save_should_beDisabledForAnEmptyName() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let task = taskManager.tasks[0]
        let host = makeHost(taskManager, task: task)

        // Act
        host.type("")
        host.tapButton("Save")

        // Assert
        XCTAssertEqual(taskManager.tasks.first { $0.id == task.id }?.name, "Fajr prayer")
    }

    func test_confirmingDelete_should_removeTheTask() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let task = taskManager.tasks[0]
        let host = makeHost(taskManager, task: task)

        // Act
        host.tap("Delete Task")
        host.pump(0.5)
        let message = host.presentedAlert?.message
        host.chooseAlertAction("Delete")

        // Assert
        XCTAssertEqual(message, "Are you sure you want to delete this task?")
        XCTAssertFalse(taskManager.tasks.contains { $0.id == task.id })
        XCTAssertEqual(taskManager.tasks.count, 2)
    }

    func test_cancellingDelete_should_keepTheTask() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let task = taskManager.tasks[0]
        let host = makeHost(taskManager, task: task)

        // Act
        host.tap("Delete Task")
        host.pump(0.5)
        host.chooseAlertAction("Cancel")

        // Assert
        XCTAssertTrue(taskManager.tasks.contains { $0.id == task.id })
        XCTAssertEqual(taskManager.tasks.count, 3)
    }
}
