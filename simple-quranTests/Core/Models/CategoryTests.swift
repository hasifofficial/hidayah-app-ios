//
//  CategoryTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class CategoryTests: XCTestCase {
    func test_defaultCategory_should_localiseDisplayNameForEveryCase() {
        // Arrange
        let categories = DefaultCategory.allCases

        // Act
        let names = categories.map(\.displayName)

        // Assert
        XCTAssertEqual(names, categories.map(\.rawValue))
        XCTAssertEqual(categories.map(\.id), categories.map(\.rawValue))
    }

    func test_defaultCategory_should_haveIconForEveryCase() {
        // Arrange
        let categories = DefaultCategory.allCases

        // Act
        let icons = categories.map(\.icon)

        // Assert
        XCTAssertEqual(icons, [
            "sunrise", "moon.stars", "sun.max", "book", "sun.haze",
            "sun.min", "sun.dust", "sunset", "moon", "bed.double"
        ])
    }

    func test_category_should_prefixDefaultIDAndUseDefaultDetails() {
        // Arrange
        let category = simple_quran.Category.default(.fajr)

        // Act
        let id = category.id

        // Assert
        XCTAssertEqual(id, "default_Fajr (Dawn Prayer)")
        XCTAssertEqual(category.name, "Fajr (Dawn Prayer)")
        XCTAssertEqual(category.icon, "sun.max")
    }

    func test_category_should_prefixCustomIDAndUseCustomDetails() {
        // Arrange
        let custom = CustomCategory(name: "Charity", icon: "heart")
        let category = simple_quran.Category.custom(custom)

        // Act
        let id = category.id

        // Assert
        XCTAssertEqual(id, "custom_\(custom.id.uuidString)")
        XCTAssertEqual(category.name, "Charity")
        XCTAssertEqual(category.icon, "heart")
    }

    func test_customCategory_should_defaultToFolderIcon() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let custom = CustomCategory(name: "Mine")

        // Assert
        XCTAssertEqual(custom.icon, "folder")
    }

    func test_category_should_roundTripThroughJSON() throws {
        // Arrange
        let categories: [simple_quran.Category] = [.default(.isha), .custom(CustomCategory(name: "Mine"))]

        // Act
        let decoded = try JSONDecoder().decode(
            [simple_quran.Category].self,
            from: JSONEncoder().encode(categories)
        )

        // Assert
        XCTAssertEqual(decoded, categories)
    }
}
