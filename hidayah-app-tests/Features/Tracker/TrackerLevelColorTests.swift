//
//  TrackerLevelColorTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

final class TrackerLevelColorTests: XCTestCase {
    func test_palette_should_giveEveryLevelItsOwnColour() {
        // Arrange
        let levels = TrackerLevelCatalog.levels

        // Act
        let colours = Set(levels.map(\.color))

        // Assert
        XCTAssertEqual(levels.count, TrackerLevel.palette.count)
        XCTAssertEqual(colours.count, levels.count)
    }

    func test_colour_should_clampLevelsOutsideThePalette() {
        // Arrange
        let first = TrackerLevel.palette.first
        let last = TrackerLevel.palette.last

        // Act
        let belowRange = TrackerLevel.color(forLevel: 0)
        let aboveRange = TrackerLevel.color(forLevel: 99)

        // Assert
        XCTAssertEqual(belowRange, first)
        XCTAssertEqual(aboveRange, last)
    }
}
