//
//  ItemSelectorTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

final class ItemSelectorTests: XCTestCase {
    func test_itemSelector_should_keepValues() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let selector = ItemSelector(title: "English", value: "en.sahih", item: 3)

        // Assert
        XCTAssertEqual(selector.title, "English")
        XCTAssertEqual(selector.value, "en.sahih")
        XCTAssertEqual(selector.item as? Int, 3)
    }
}
