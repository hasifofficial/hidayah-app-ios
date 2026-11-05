//
//  TrackerLevelsViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class TrackerLevelsViewTests: XCTestCase {
    func test_body_should_showTheFirstLevelAsCurrent() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = ViewHost(NavigationStack { TrackerLevelsView(taskManager: taskManager) })
        host.pump(0.8)

        // Assert
        XCTAssertTrue(host.contains("Level 1"))
        XCTAssertTrue(host.contains("0 pts"))
        XCTAssertTrue(host.contains("100 XP to next level"))
        XCTAssertTrue(host.contains("How to earn points"))
        XCTAssertTrue(host.contains("Current"))
        XCTAssertTrue(host.contains("You are here"))
        XCTAssertTrue(host.contains("Reach 100 points to unlock"))
        XCTAssertTrue(host.contains("5000+ pts") || host.contains("5,000+ pts"))
        XCTAssertTrue(host.contains("Luminous"))
    }

    func test_body_should_unlockLevelsUpToThePointsEarned() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record([3, 3])

        // Act
        let host = ViewHost(NavigationStack { TrackerLevelsView(taskManager: taskManager) })
        host.pump(0.8)

        // Assert
        XCTAssertTrue(host.contains("Level 2"))
        XCTAssertTrue(host.contains("160 pts"))
        XCTAssertTrue(host.contains("250 XP to next level"))
        XCTAssertFalse(host.contains("Reach 100 points to unlock"))
        XCTAssertTrue(host.contains("Reach 250 points to unlock"))
    }

    func test_body_should_hideNextLevelAtTheTopLevel() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record(Array(repeating: 3, count: 63))

        // Act
        let host = ViewHost(NavigationStack { TrackerLevelsView(taskManager: taskManager) })
        host.pump(0.8)

        // Assert
        XCTAssertEqual(taskManager.stats.level, 10)
        XCTAssertTrue(host.contains("Level 10"))
        XCTAssertFalse(host.contains("XP to next level"))
        XCTAssertFalse(host.contains("points to unlock"))
    }
}
