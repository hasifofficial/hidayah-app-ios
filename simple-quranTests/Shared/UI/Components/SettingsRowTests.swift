//
//  SettingsRowTests.swift
//  simple-quranTests
//

import MessageUI
import SafariServices
import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
private final class FormState: ObservableObject {
    @Published var text = ""
    @Published var icon = "star"
    @Published var isOn = false
}

private struct RowsHarness: View {
    @ObservedObject var state: FormState
    var onAction: () -> Void = {}

    var body: some View {
        List {
            SettingsSectionHeader(title: "General")
            SettingsSectionHeader(title: "More", topPadding: 4)
            SettingsActionRow(
                icon: "globe",
                title: "Language",
                value: "English",
                action: onAction
            )
            SettingsActionRow(
                icon: "info.circle",
                title: "Info",
                showsDisclosure: false,
                action: onAction
            )
            SettingsToggleRow(
                icon: "bell",
                title: "Reminders",
                isOn: $state.isOn
            )
        }
    }
}

@MainActor
final class SettingsRowTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_settingsRows_should_showValuesAndRunActions() {
        // Arrange
        let state = FormState()
        var actions = 0
        let host = sceneHost(RowsHarness(state: state, onAction: { actions += 1 }))

        // Act
        host.tap("Language")
        host.tap("Info")
        host.toggleSwitch()

        // Assert
        XCTAssertTrue(host.contains("General"))
        XCTAssertTrue(host.contains("More"))
        XCTAssertTrue(host.contains("English"))
        XCTAssertTrue(host.contains("Reminders"))
        XCTAssertEqual(actions, 2)
        XCTAssertTrue(state.isOn)
    }
}
