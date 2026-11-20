//
//  TaskDetailsTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class TaskDetailsTests: XCTestCase {
    func test_taskDetails_should_defaultToIncomplete() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let task = TaskDetails(name: "Fajr", category: .default(.fajr))

        // Assert
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(task.name, "Fajr")
    }
}
