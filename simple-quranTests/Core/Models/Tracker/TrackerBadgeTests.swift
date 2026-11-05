//
//  TrackerBadgeTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerBadgeTests: XCTestCase {
    func test_badge_should_exposeIconAndTargetForEveryCase() {
        // Arrange
        let expected: [TrackerBadge: (String, Int)] = [
            .firstStep: ("sparkles", 1),
            .streak3: ("flame.fill", 3),
            .streak7: ("flame.fill", 7),
            .streak30: ("flame.fill", 30),
            .perfectDay: ("star.circle.fill", 1),
            .perfectTen: ("star.circle.fill", 10),
            .century: ("trophy.fill", 100),
            .devoted: ("trophy.fill", 1_000)
        ]

        // Act
        let actual = TrackerBadge.allCases.map { ($0, $0.icon, $0.target) }

        // Assert
        XCTAssertEqual(actual.count, expected.count)
        for (badge, icon, target) in actual {
            XCTAssertEqual(icon, expected[badge]?.0, "\(badge)")
            XCTAssertEqual(target, expected[badge]?.1, "\(badge)")
            XCTAssertEqual(badge.id, badge.rawValue)
        }
    }

    func test_badge_should_localiseTitleAndDetail() {
        // Arrange
        let badges = TrackerBadge.allCases

        // Act
        let first = TrackerBadge.firstStep

        // Assert
        XCTAssertEqual(first.title, "First Step")
        XCTAssertEqual(first.detail, "Complete your first task.")
        for badge in badges {
            XCTAssertNotEqual(badge.title, "tracker_badge_\(badge.rawValue)_title")
            XCTAssertNotEqual(badge.detail, "tracker_badge_\(badge.rawValue)_detail")
        }
    }
}
