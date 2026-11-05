//
//  TrackerLevelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class TrackerLevelTests: XCTestCase {
    func test_levelCatalog_should_listOneLevelPerThreshold() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let levels = TrackerLevelCatalog.levels

        // Assert
        XCTAssertEqual(levels.map(\.number), Array(1...10))
        XCTAssertEqual(levels.map(\.id), Array(1...10))
        XCTAssertEqual(levels.first?.startPoints, 0)
        XCTAssertEqual(levels.first?.endPoints, 99)
        XCTAssertEqual(levels.last?.startPoints, 5_000)
        XCTAssertNil(levels.last?.endPoints)
    }

    func test_levelText_should_formatRangeAndUnlockText() {
        // Arrange
        let levels = TrackerLevelCatalog.levels

        // Act
        let first = levels[0]
        let last = levels[9]

        // Assert
        XCTAssertEqual(first.title, "First Step")
        XCTAssertEqual(first.rangeText, "0–99 pts")
        XCTAssertEqual(last.rangeText, "5000+ pts")
        XCTAssertEqual(last.unlockText, "Reach 5000 points to unlock")
    }
}
