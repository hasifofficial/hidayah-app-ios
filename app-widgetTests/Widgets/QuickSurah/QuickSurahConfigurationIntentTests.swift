//
//  QuickSurahConfigurationIntentTests.swift
//  app-widgetTests
//

import AppIntents
import WidgetKit
import XCTest

@MainActor
final class QuickSurahConfigurationIntentTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_configurationIntent_should_haveNoSurahsByDefault() {
        // Arrange
        let make = { QuickSurahConfigurationIntent() }

        // Act
        let intent = make()

        // Assert
        XCTAssertNil(intent.surahs)
        XCTAssertEqual(QuickSurahConfigurationIntent.title.key, "widget_quick_access_display_name")
    }
}
