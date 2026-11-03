//
//  Collection+ExtensionsTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class CollectionExtensionsTests: XCTestCase {
    func test_safeSubscript_should_returnElementInsideBounds() {
        // Arrange
        let values = ["a", "b"]

        // Act
        let element = values[safe: 1]

        // Assert
        XCTAssertEqual(element, "b")
    }

    func test_safeSubscript_should_returnNilOutsideBounds() {
        // Arrange
        let values = ["a", "b"]

        // Act
        let element = values[safe: 2]

        // Assert
        XCTAssertNil(element)
    }
}
