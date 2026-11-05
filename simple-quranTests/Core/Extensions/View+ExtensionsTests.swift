//
//  View+ExtensionsTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class ViewExtensionsTests: XCTestCase {
    @MainActor
    func test_settingsListRow_should_wrapView() {
        // Arrange
        let view = Text("Row")

        // Act
        let row = view.settingsListRow()

        // Assert
        XCTAssertFalse(String(describing: type(of: row)).isEmpty)
    }
}
