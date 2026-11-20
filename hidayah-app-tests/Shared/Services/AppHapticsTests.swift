//
//  AppHapticsTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

final class AppHapticsTests: XCTestCase {
    @MainActor
    func test_appHaptics_should_playEveryFeedbackWithoutCrashing() {
        // Arrange
        let feedback: [() -> Void] = [AppHaptics.tap, AppHaptics.selection, AppHaptics.success]

        // Act
        feedback.forEach { $0() }

        // Assert
        XCTAssertEqual(feedback.count, 3)
    }
}
