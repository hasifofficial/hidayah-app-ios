//
//  AddCategoryViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class AddCategoryViewTests: XCTestCase {
    private func makeHost(_ taskManager: TaskManager) -> ViewHost<some View> {
        let host = ViewHost(AddCategoryView().environment(taskManager))
        host.pump(0.5)
        return host
    }

    func test_body_should_showTheFormAndIcons() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = makeHost(taskManager)

        // Assert
        XCTAssertTrue(host.contains("Create a Category"))
        XCTAssertTrue(host.contains("Category Name"))
        XCTAssertTrue(host.contains("Icon"))
        XCTAssertTrue(host.labels().contains("hands.and.sparkles"))
    }

    func test_addCategory_should_saveTheNameAndChosenIcon() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let host = makeHost(taskManager)

        // Act
        host.type(" Evening Adhkar ")
        host.tapButton("moon.stars")
        host.tapButton("Add Category")

        // Assert
        XCTAssertEqual(taskManager.customCategories.map(\.name), ["Evening Adhkar"])
        XCTAssertEqual(taskManager.customCategories.first?.icon, "moon.stars")
    }

    func test_addCategory_should_doNothingWithoutAName() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        let host = makeHost(taskManager)

        // Act
        host.tapButton("Add Category")
        host.tapButton("Cancel")

        // Assert
        XCTAssertTrue(taskManager.customCategories.isEmpty)
    }
}
