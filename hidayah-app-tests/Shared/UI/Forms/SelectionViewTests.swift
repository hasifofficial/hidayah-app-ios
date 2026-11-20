//
//  SelectionViewTests.swift
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
final class SelectionViewTests: ViewsTestCase {
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

    private var editions: [ItemSelector] {
        [
            ItemSelector(title: "Alafasy", value: "ar.alafasy", item: nil),
            ItemSelector(title: "Husary", value: "ar.husary", item: nil)
        ]
    }

    func test_selectionView_should_listItemsAndTitle() {
        // Arrange
        let state = SheetState()

        // Act
        let host = present(state) {
            SelectionView(
                title: "Choose recitation",
                items: self.editions,
                selectedValue: "ar.husary",
                onSelect: { _ in }
            )
        }

        // Assert
        XCTAssertTrue(host.contains("Choose recitation"))
        XCTAssertTrue(host.contains("Alafasy"))
        XCTAssertTrue(host.contains("Husary"))
    }

    func test_selectionView_should_selectItemAndDismiss() {
        // Arrange
        let state = SheetState()
        var selected: [String] = []
        let host = present(state) {
            SelectionView(
                title: "Choose recitation",
                items: self.editions,
                selectedValue: nil,
                onSelect: { selected.append($0.value) }
            )
        }

        // Act
        host.tap("Husary")
        host.pump(0.8)

        // Assert
        XCTAssertEqual(selected, ["ar.husary"])
        XCTAssertFalse(state.isPresented)
    }

    func test_selectionView_should_dismissWhenCloseTapped() {
        // Arrange
        let state = SheetState()
        var selected: [String] = []
        let host = present(state) {
            SelectionView(
                title: "Choose translation",
                items: self.editions,
                selectedValue: "ar.alafasy",
                onSelect: { selected.append($0.value) }
            )
        }

        // Act
        host.tap("Close")
        host.pump(0.8)

        // Assert
        XCTAssertTrue(selected.isEmpty)
        XCTAssertFalse(state.isPresented)
    }
}
