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

    func test_body_should_showDayStartRow_withCurrentTime() {
        // Arrange
        let host = ViewHost(
            NavigationStack {
                TrackerSettingsView(
                    onManageCategories: {},
                    onResetDailyProgress: {},
                    onResetAll: {},
                    dayStartMinutes: 4 * 60
                )
            }
        )
        host.pump(0.5)

        // Act
        let labels = host.labels()

        // Assert
        XCTAssertTrue(host.contains("Daily Reset"), "\(labels)")
        XCTAssertTrue(host.contains("New Day Starts"), "\(labels)")
        XCTAssertTrue(host.contains(TrackerSettingsView.timeLabel(forMinutes: 240)), "\(labels)")
    }

    func test_timeLabel_should_formatMinutesAsTimeOfDay() {
        // Arrange
        let minutes = [0, 270]

        // Act
        let labels = minutes.map(TrackerSettingsView.timeLabel(forMinutes:))

        // Assert
        XCTAssertNotEqual(labels[0], labels[1])
        XCTAssertTrue(labels[1].contains("4") && labels[1].contains("30"), labels[1])
    }

    func test_dayStartRow_should_openSelectionList_andSaveChoice() {
        // Arrange
        var chosen: Int?
        let host = ViewHost(
            NavigationStack {
                TrackerSettingsView(
                    onManageCategories: {},
                    onResetDailyProgress: {},
                    onResetAll: {},
                    onChangeDayStart: { chosen = $0 }
                )
            }
        )
        host.pump(0.5)
        let fourAM = TrackerSettingsView.timeLabel(forMinutes: 240)

        // Act
        host.tap("New Day Starts")
        host.pump(until: { host.contains(fourAM) })
        host.tap(fourAM)
        host.pump(0.8)

        // Assert
        XCTAssertEqual(chosen, 240)
        XCTAssertTrue(host.contains(fourAM))
    }
}
