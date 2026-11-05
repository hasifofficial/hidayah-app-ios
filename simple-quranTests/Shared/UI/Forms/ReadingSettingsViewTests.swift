//
//  ReadingSettingsViewTests.swift
//  simple-quranTests
//
//  ReadingSettingsView and SelectionView, presented as sheets so
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
final class ReadingSettingsViewTests: ViewsTestCase {
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
        let host = present(state) { ReadingSettingsView() }

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
        let host = present(state) { ReadingSettingsView() }

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
        let host = present(state) { ReadingSettingsView() }

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
        let host = present(state) { ReadingSettingsView() }
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

    func test_quranReadingSettingsView_should_hideReadingMode_byDefault() {
        // Arrange
        let state = SheetState()

        // Act
        let host = present(state) { ReadingSettingsView() }

        // Assert
        XCTAssertFalse(host.contains("Reading Mode"))
        XCTAssertTrue(host.contains("Preview"))
    }

    func test_quranReadingSettingsView_should_saveMushafMode_when_chosen() {
        // Arrange
        let state = SheetState()
        let host = present(state) { ReadingSettingsView(showsReadingMode: true) }
        let showedPicker = host.contains("Reading Mode")

        // Act
        // Accessibility activation doesn't pick a segment on every iOS
        // version, so select it on the control the picker is drawn with.
        let control = host.firstView(of: UISegmentedControl.self)
        control?.selectedSegmentIndex = 1
        control?.sendActions(for: .valueChanged)
        host.pump(0.3)

        // Assert
        XCTAssertTrue(showedPicker)
        XCTAssertEqual(Storage.load(key: .quranReadingMode) as? String, "mushaf")
        XCTAssertTrue(host.contains("Mushaf pages are shown as printed"))
        XCTAssertFalse(host.contains("Preview"))
    }

    func test_quranReadingSettingsView_should_saveOnePage_when_chosenForWideScreens() {
        // Arrange
        Storage.save(.quranReadingMode, "mushaf")
        let state = SheetState()
        let host = present(state) { ReadingSettingsView(showsReadingMode: true) }
        let showedChoice = host.contains("On Wide Screens")

        // Act
        let controls = host.allViews(of: UISegmentedControl.self)
        controls.last?.selectedSegmentIndex = 1
        controls.last?.sendActions(for: .valueChanged)
        host.pump(0.3)

        // Assert
        XCTAssertTrue(showedChoice)
        XCTAssertEqual(Storage.load(key: .mushafShowsSpread) as? Bool, false)
    }

    func test_quranReadingSettingsView_should_saveScroll_when_chosenForPageTurning() {
        // Arrange
        Storage.save(.quranReadingMode, "mushaf")
        let state = SheetState()
        let host = present(state) { ReadingSettingsView(showsReadingMode: true) }
        let showedChoice = host.contains("Page Turning")

        // Act
        let pageTurning = host.allViews(of: UISegmentedControl.self).first {
            $0.titleForSegment(at: 0) == "Swipe"
        }
        guard let pageTurning else {
            return XCTFail("No page turning picker")
        }
        pageTurning.selectedSegmentIndex = 1
        pageTurning.sendActions(for: .valueChanged)
        host.pump(0.3)

        // Assert
        XCTAssertTrue(showedChoice)
        XCTAssertEqual(Storage.load(key: .mushafScrollsVertically) as? Bool, true)
    }

    func test_quranReadingSettingsView_should_hideWideScreenChoice_inListMode() {
        // Arrange
        let state = SheetState()

        // Act
        let host = present(state) { ReadingSettingsView(showsReadingMode: true) }

        // Assert
        XCTAssertFalse(host.contains("On Wide Screens"))
    }

    func test_quranReadingSettingsView_should_resetModeToList() {
        // Arrange
        Storage.save(.quranReadingMode, "mushaf")
        Storage.save(.mushafShowsSpread, false)
        let state = SheetState()
        let host = present(state) { ReadingSettingsView(showsReadingMode: true) }

        // Act
        host.tap("Reset")
        host.pump(0.3)

        // Assert
        XCTAssertEqual(Storage.load(key: .quranReadingMode) as? String, "list")
        XCTAssertEqual(Storage.load(key: .mushafShowsSpread) as? Bool, true)
        XCTAssertTrue(host.contains("Preview"))
    }

    func test_quranReadingSettingsView_should_ignoreMushafMode_when_pickerIsHidden() {
        // Arrange
        Storage.save(.quranReadingMode, "mushaf")
        let state = SheetState()

        // Act
        let host = present(state) { ReadingSettingsView() }

        // Assert
        XCTAssertTrue(host.contains("Preview"))
        XCTAssertFalse(host.contains("Mushaf pages are shown as printed"))
    }

    func test_quranReadingSettingsView_should_dismissWhenDoneTapped() {
        // Arrange
        let state = SheetState()
        let host = present(state) { ReadingSettingsView() }

        // Act
        host.tap("Done")
        host.pump(0.8)

        // Assert
        XCTAssertFalse(state.isPresented)
    }
}
