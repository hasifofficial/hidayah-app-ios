//
//  WidgetContextTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class WidgetContextTests: XCTestCase {
    func test_widgetContext_should_decodeSnapshotFromOlderBuild() throws {
        // Arrange
        let json = #"{"progress":0.5,"completedTasks":1,"totalTasks":2,"upcomingTasks":[]}"#

        // Act
        let context = try JSONDecoder().decode(WidgetContext.self, from: Data(json.utf8))

        // Assert
        XCTAssertEqual(context.progress, 0.5)
        XCTAssertNil(context.dayKey)
        XCTAssertNil(context.resetUpcomingTasks)
    }
}
