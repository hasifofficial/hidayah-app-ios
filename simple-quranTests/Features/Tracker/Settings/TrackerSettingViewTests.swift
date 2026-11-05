//
//  TrackerSettingViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class TrackerSettingsViewTests: XCTestCase {
    private var manageOpened = 0

    private var dailyResets = 0

    private var fullResets = 0

    private func makeHost() -> ViewHost<some View> {
        let host = ViewHost(
            NavigationStack {
                TrackerSettingsView(
                    onManageCategories: { self.manageOpened += 1 },
                    onResetDailyProgress: { self.dailyResets += 1 },
                    onResetAll: { self.fullResets += 1 }
                )
            }
        )
        host.pump(0.5)
        return host
    }

    func test_manageCategories_should_callItsHandler() {
        // Arrange
        let host = makeHost()

        // Act
        host.tap("Manage Categories")

        // Assert
        XCTAssertEqual(manageOpened, 1)
        XCTAssertNil(host.presentedAlert)
    }

    func test_resetToday_should_askThenResetDailyProgress() {
        // Arrange
        let host = makeHost()

        // Act
        host.tap("Reset Today's Progress")
        host.pump(0.5)
        let alert = host.presentedAlert
        let title = alert?.title
        let message = alert?.message
        host.chooseAlertAction("Reset")

        // Assert
        XCTAssertEqual(title, "Reset Today's Progress?")
        XCTAssertEqual(message, "Are you sure you want to reset today's progress?")
        XCTAssertEqual(dailyResets, 1)
        XCTAssertEqual(fullResets, 0)
    }

    func test_resetAll_should_askThenResetEverything() {
        // Arrange
        let host = makeHost()

        // Act
        host.tap("Reset All")
        host.pump(0.5)
        let title = host.presentedAlert?.title
        let message = host.presentedAlert?.message
        host.chooseAlertAction("Reset")

        // Assert
        XCTAssertEqual(title, "Reset All?")
        XCTAssertTrue(message?.hasPrefix("Reset all will restore everything") == true)
        XCTAssertEqual(fullResets, 1)
        XCTAssertEqual(dailyResets, 0)
    }

    func test_cancel_should_resetNothing() {
        // Arrange
        let host = makeHost()

        // Act
        host.tap("Reset All")
        host.pump(0.5)
        host.chooseAlertAction("Cancel")

        // Assert
        XCTAssertEqual(fullResets, 0)
        XCTAssertEqual(dailyResets, 0)
    }
}
