//
//  QuranReadingSettingsViewTests.swift
//  simple-quranTests
//
//  QuranReadingSettingsView and SelectionView, presented as sheets so
//  their dismiss actions can be observed.
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
private final class SheetState: ObservableObject {
    @Published var isPresented = true
}

private struct SheetHarness<Sheet: View>: View {
    @ObservedObject var state: SheetState
    let sheet: () -> Sheet

    var body: some View {
        Color.clear
            .sheet(isPresented: $state.isPresented) {
                sheet()
            }
    }
}

@MainActor
final class QuranReadingSettingsViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func present<Sheet: View>(
        _ state: SheetState,
        @ViewBuilder _ sheet: @escaping () -> Sheet
    ) -> ViewHost<SheetHarness<Sheet>> {

        let host = sceneHost(
            SheetHarness(state: state, sheet: sheet),
            size: CGSize(width: 402, height: 874)
        )
        host.pump(0.8)
        return host
    }

    func test_quranReadingSettingsView_should_showPreviewAndDefaults() {
        // Arrange
        let state = SheetState()

        // Act
        let host = present(state) { QuranReadingSettingsView() }

        // Assert
        XCTAssertTrue(host.contains("Quran Reading"))
        XCTAssertTrue(host.contains("Preview"))
        XCTAssertTrue(host.contains("By time,"))
        XCTAssertTrue(host.contains("Indeed, mankind is in loss."))
        XCTAssertTrue(host.contains("وَٱلْعَصْرِ"))
        XCTAssertTrue(host.contains("22 pt"))
        XCTAssertTrue(host.contains("Show Translation"))
    }

    func test_quranReadingSettingsView_should_hidePreviewTranslationWhenToggledOff() {
        // Arrange
        let state = SheetState()
        let host = present(state) { QuranReadingSettingsView() }

        // Act
        host.toggleSwitch()
        host.pump(0.3)

        // Assert
        XCTAssertEqual(Storage.load(key: .quranShowTranslation) as? Bool, false)
        XCTAssertFalse(host.contains("By time,"))
    }

    func test_quranReadingSettingsView_should_changeFontSizeWithSlider() {
        // Arrange
        let state = SheetState()
        let host = present(state) { QuranReadingSettingsView() }

        // Act
        host.slide(toFraction: 7.0 / 18.0)
        host.pump(0.3)

        // Assert
        XCTAssertEqual(Storage.load(key: .quranArabicFontSize) as? Double, 23)
        XCTAssertTrue(host.contains("23 pt"))
    }

    func test_quranReadingSettingsView_should_resetToDefaults() {
        // Arrange
        Storage.save(.quranArabicFontSize, 30.0)
        Storage.save(.quranShowTranslation, false)
        let state = SheetState()
        let host = present(state) { QuranReadingSettingsView() }
        let before = host.contains("30 pt")

        // Act
        host.tap("Reset")
        host.pump(0.3)

        // Assert
        XCTAssertTrue(before)
        XCTAssertTrue(host.contains("22 pt"))
        XCTAssertTrue(host.contains("By time,"))
        XCTAssertEqual(Storage.load(key: .quranShowTranslation) as? Bool, true)
    }

    func test_quranReadingSettingsView_should_dismissWhenDoneTapped() {
        // Arrange
        let state = SheetState()
        let host = present(state) { QuranReadingSettingsView() }

        // Act
        host.tap("Done")
        host.pump(0.8)

        // Assert
        XCTAssertFalse(state.isPresented)
    }
}
