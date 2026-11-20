//
//  TrackerCheerStateTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerCheerStateTests: XCTestCase {
    func test_cheerState_should_defaultToTodayWithoutMilestones() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let state = TrackerCheerState()

        // Assert
        XCTAssertEqual(state.dayKey, TrackerDayKey.today())
        XCTAssertTrue(state.sentMilestones.isEmpty)
    }

    func test_cheerState_should_roundTripThroughJSON() throws {
        // Arrange
        let state = TrackerCheerState(dayKey: "2026-03-10", sentMilestones: [25, 50])

        // Act
        let decoded = try JSONDecoder().decode(
            TrackerCheerState.self,
            from: JSONEncoder().encode(state)
        )

        // Assert
        XCTAssertEqual(decoded.dayKey, "2026-03-10")
        XCTAssertEqual(decoded.sentMilestones, [25, 50])
    }
}
