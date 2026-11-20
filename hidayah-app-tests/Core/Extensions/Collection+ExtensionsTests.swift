//
//  Collection+ExtensionsTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

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
