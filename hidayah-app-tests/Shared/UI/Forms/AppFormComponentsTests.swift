//
//  AppFormComponentsTests.swift
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

private struct FormHarness: View {
    @ObservedObject var state: FormState
    var isEnabled = true
    var onPrimary: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack {
                AppFormHeader(
                    icon: "folder",
                    title: "New Category",
                    subtitle: "Group your tasks"
                )
                AppFormCard(title: "Details") {
                    AppTextField(
                        label: "Name",
                        placeholder: "Category name",
                        text: $state.text
                    )
                    AppIconPicker(
                        selection: $state.icon,
                        icons: ["star", "moon", "sun.max"]
                    )
                }
                AppPrimaryButton(
                    title: "Save",
                    icon: "checkmark",
                    isEnabled: isEnabled,
                    action: onPrimary
                )
            }
        }
    }
}

@MainActor
final class AppFormComponentsTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_appFormComponents_should_showTitlesAndFields() {
        // Arrange
        let state = FormState()

        // Act
        let host = sceneHost(FormHarness(state: state))

        // Assert
        XCTAssertTrue(host.contains("New Category"))
        XCTAssertTrue(host.contains("Group your tasks"))
        XCTAssertTrue(host.contains("Details"))
        XCTAssertTrue(host.contains("Name"))
        XCTAssertTrue(host.contains("Save"))
        XCTAssertNotNil(host.firstView(of: UITextField.self))
    }

    func test_appTextField_should_updateBindingWhenTyping() {
        // Arrange
        let state = FormState()
        let host = sceneHost(FormHarness(state: state))
        let field = host.firstView(of: UITextField.self)

        // Act
        field?.becomeFirstResponder()
        field?.insertText("Dhikr")
        host.pump(0.2)

        // Assert
        XCTAssertEqual(state.text, "Dhikr")
    }

    func test_appIconPicker_should_selectTappedIcon() {
        // Arrange
        let state = FormState()
        let host = sceneHost(FormHarness(state: state))

        // Act
        host.tap("moon")

        // Assert
        XCTAssertEqual(state.icon, "moon")
    }

    func test_appPrimaryButton_should_runActionWhenEnabled() {
        // Arrange
        var taps = 0
        let host = sceneHost(FormHarness(state: FormState(), onPrimary: { taps += 1 }))

        // Act
        host.tap("Save")

        // Assert
        XCTAssertEqual(taps, 1)
    }

    func test_appPrimaryButton_should_ignoreTapsWhenDisabled() {
        // Arrange
        var taps = 0
        let host = sceneHost(
            FormHarness(state: FormState(), isEnabled: false, onPrimary: { taps += 1 })
        )

        // Act
        host.tap("Save")

        // Assert
        XCTAssertEqual(taps, 0)
    }
}
