//
//  CategoryTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

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

    func test_defaultCategoryFromID_should_matchEveryDefaultCategoryID() {
        // Arrange
        let ids = DefaultCategory.allCases.map { hidayah_app.Category.default($0).id }

        // Act
        let parsed = ids.map(DefaultCategory.init(categoryID:))

        // Assert
        XCTAssertEqual(parsed, DefaultCategory.allCases)
    }

    func test_defaultCategoryFromID_should_returnNil_when_idIsCustomOrUnknown() {
        // Arrange
        let custom = hidayah_app.Category.custom(CustomCategory(name: "Mine")).id

        // Act
        let fromCustom = DefaultCategory(categoryID: custom)
        let fromUnknown = DefaultCategory(categoryID: "default_Nope")

        // Assert
        XCTAssertNil(fromCustom)
        XCTAssertNil(fromUnknown)
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
        let category = hidayah_app.Category.default(.fajr)

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
        let category = hidayah_app.Category.custom(custom)

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
        let categories: [hidayah_app.Category] = [.default(.isha), .custom(CustomCategory(name: "Mine"))]

        // Act
        let decoded = try JSONDecoder().decode(
            [hidayah_app.Category].self,
            from: JSONEncoder().encode(categories)
        )

        // Assert
        XCTAssertEqual(decoded, categories)
    }
}
