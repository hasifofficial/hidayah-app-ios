//
//  ManageCategoryViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class ManageCategoryViewTests: XCTestCase {
    func test_body_should_showEmptyStateWithoutCustomCategories() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = ViewHost(NavigationStack { ManageCategoryView(taskManager: taskManager) })
        host.pump(0.5)

        // Assert
        XCTAssertTrue(host.contains("You have no custom categories"))
        XCTAssertTrue(host.contains("Tap on + button and choose add category to add new one"))
        XCTAssertTrue(host.contains("Manage Categories"))
    }

    func test_body_should_listCustomCategories() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()
        taskManager.addCustomCategory(name: "Evening Adhkar", icon: "moon.stars")
        taskManager.addCustomCategory(name: "Charity", icon: "heart")

        // Act
        let host = ViewHost(NavigationStack { ManageCategoryView(taskManager: taskManager) })
        host.pump(0.5)

        // Assert
        XCTAssertTrue(host.contains("Custom Categories"))
        XCTAssertTrue(host.contains("Evening Adhkar"))
        XCTAssertTrue(host.contains("Charity"))
        XCTAssertTrue(host.contains("Swipe to delete a category."))
        XCTAssertFalse(host.contains("You have no custom categories"))
    }
}
