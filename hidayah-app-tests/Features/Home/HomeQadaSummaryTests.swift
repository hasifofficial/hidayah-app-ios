//
//  HomeQadaSummaryTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class HomeQadaSummaryTests: XCTestCase {
    func test_message_should_countFastsLeft_when_noneMadeUpYet() {
        // Arrange
        let remaining = 6, madeUp = 0, owed = 6

        // Act
        let message = HomeQadaSummary.message(remaining: remaining, madeUp: madeUp, owed: owed)

        // Assert
        XCTAssertEqual(message, "6 fasts left to make up")
    }

    func test_message_should_addProgress_when_someMadeUp() {
        // Arrange
        let remaining = 3, madeUp = 5, owed = 8

        // Act
        let message = HomeQadaSummary.message(remaining: remaining, madeUp: madeUp, owed: owed)

        // Assert
        XCTAssertEqual(message, "3 fasts left to make up · 5 of 8 done")
    }

    func test_message_should_beSingular_when_oneFastLeft() {
        // Arrange
        let remaining = 1, madeUp = 4, owed = 5

        // Act
        let message = HomeQadaSummary.message(remaining: remaining, madeUp: madeUp, owed: owed)

        // Assert
        XCTAssertEqual(message, "1 fast left to make up · 4 of 5 done")
    }

    func test_deadline_should_countDaysUntilRamadan() {
        // Arrange & Act & Assert
        XCTAssertEqual(HomeQadaSummary.deadline(days: 72), "Ramadan in 72 days")
        XCTAssertEqual(HomeQadaSummary.deadline(days: 1), "Ramadan starts tomorrow")
        XCTAssertEqual(HomeQadaSummary.deadline(days: 0), "Ramadan starts today")
    }

    func test_isDeadlineNear_should_beTrue_inRamadansLastMonth() {
        // Arrange & Act & Assert
        XCTAssertTrue(HomeQadaSummary.isDeadlineNear(30))
        XCTAssertTrue(HomeQadaSummary.isDeadlineNear(5))
        XCTAssertFalse(HomeQadaSummary.isDeadlineNear(31))
    }
}
