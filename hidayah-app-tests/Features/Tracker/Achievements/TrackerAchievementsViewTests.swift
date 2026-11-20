//
//  TrackerAchievementsViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class TrackerAchievementsViewTests: XCTestCase {
    func test_body_should_showLockedBadgesForANewUser() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = ViewHost(NavigationStack { TrackerAchievementsView(taskManager: taskManager) })
        host.pump(1.2)

        // Assert
        XCTAssertTrue(host.contains("Level 1"))
        XCTAssertTrue(host.contains("0 pts"))
        XCTAssertTrue(host.contains("100 XP to next level"))
        XCTAssertTrue(host.contains("Current streak"))
        XCTAssertTrue(host.contains("Longest streak"))
        XCTAssertTrue(host.contains("0 of 8 unlocked"))
        XCTAssertTrue(host.contains("Devoted"))
        XCTAssertTrue(host.contains("Share achievements"))
        XCTAssertFalse(host.contains("Share badge"))
    }

    func test_body_should_offerSharingForUnlockedBadges() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record([3, 3, 3])

        // Act
        let host = ViewHost(NavigationStack { TrackerAchievementsView(taskManager: taskManager) })
        host.pump(1.2)

        // Assert
        XCTAssertEqual(taskManager.stats.unlockedBadges, [.firstStep, .streak3, .perfectDay])
        XCTAssertTrue(host.contains("3 of 8 unlocked"))
        XCTAssertTrue(host.contains("240 pts"))
        XCTAssertTrue(host.contains("Share badge"))
    }

    func test_body_should_showEveryBadgeUnlockedAtTheTop() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record(Array(repeating: 3, count: 34))

        // Act
        let host = ViewHost(NavigationStack { TrackerAchievementsView(taskManager: taskManager) })
        host.pump(1.2)

        // Assert
        XCTAssertTrue(taskManager.stats.unlockedBadges.isSuperset(of: [.streak30, .perfectTen, .century]))
        XCTAssertTrue(host.contains("7 of 8 unlocked"))
        XCTAssertTrue(host.contains("34"))
    }
}
