//
//  AddTaskViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class AddTaskViewTests: XCTestCase {
    private func makeHost(_ taskManager: TaskManager) -> ViewHost<some View> {
        let host = ViewHost(AddTaskView().environment(taskManager))
        host.pump(0.5)
        return host
    }

    func test_body_should_preselectTheFirstCategory() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = makeHost(taskManager)

        // Assert
        XCTAssertTrue(host.contains("Add a New Task"))
        XCTAssertTrue(host.contains("Give it a clear name and choose a category."))
        XCTAssertTrue(host.contains("Upon Waking Up"))
        XCTAssertTrue(host.contains("Cancel"))
    }

    func test_addTask_should_saveATrimmedTaskInTheSelectedCategory() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let host = makeHost(taskManager)

        // Act
        host.type("  Read Quran after Fajr  ")
        host.tapButton("Add Task")

        // Assert
        let added = taskManager.tasks.last
        XCTAssertEqual(taskManager.tasks.count, 4)
        XCTAssertEqual(added?.name, "Read Quran after Fajr")
        XCTAssertEqual(added?.category.id, simple_quran.Category.default(.morning).id)
    }

    func test_addTask_should_doNothingWithoutAName() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let host = makeHost(taskManager)

        // Act
        host.type("   ")
        host.tapButton("Add Task")
        host.tapButton("Cancel")

        // Assert
        XCTAssertEqual(taskManager.tasks.count, 3)
    }
}
