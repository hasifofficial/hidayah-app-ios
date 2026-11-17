//
//  HomeTrackerSummaryTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class HomeTrackerSummaryTests: XCTestCase {
    func test_message_should_inviteToAddTasks_when_noTasks() {
        // Arrange
        let completed = 0, total = 0

        // Act
        let message = HomeTrackerSummary.message(completed: completed, total: total)

        // Assert
        XCTAssertEqual(message, "Add tasks in Tracker to build your daily routine.")
    }

    func test_message_should_countWaitingTasks_when_nothingDone() {
        // Arrange
        let completed = 0, total = 8

        // Act
        let message = HomeTrackerSummary.message(completed: completed, total: total)

        // Assert
        XCTAssertEqual(message, "8 tasks are waiting for you today. Bismillah, let’s begin.")
    }

    func test_message_should_showRemainingAndPercent_when_partlyDone() {
        // Arrange
        let completed = 5, total = 8

        // Act
        let message = HomeTrackerSummary.message(completed: completed, total: total)

        // Assert
        XCTAssertEqual(message, "3 more to go and you’re 63% there. Keep going!")
    }

    func test_message_should_sayAlmostThere_when_oneLeft() {
        // Arrange
        let completed = 7, total = 8

        // Act
        let message = HomeTrackerSummary.message(completed: completed, total: total)

        // Assert
        XCTAssertEqual(message, "Just one more task to go. You’re almost there!")
    }

    func test_message_should_celebrate_when_allDone() {
        // Arrange
        let completed = 8, total = 8

        // Act
        let message = HomeTrackerSummary.message(completed: completed, total: total)

        // Assert
        XCTAssertEqual(message, "Alhamdulillah, you’ve completed everything today!")
    }
}
