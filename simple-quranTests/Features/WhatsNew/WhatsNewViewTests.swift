//
//  WhatsNewViewTests.swift
//  simple-quranTests
//
//  WhatsNewView, presented as a sheet so its dismiss can be observed.
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
private final class WhatsNewSheetState: ObservableObject {
    @Published var isPresented = true
}

private struct WhatsNewHarness: View {
    @ObservedObject var state: WhatsNewSheetState

    var body: some View {
        Color.clear
            .sheet(isPresented: $state.isPresented) {
                WhatsNewView()
            }
    }
}

@MainActor
final class WhatsNewViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func present(_ state: WhatsNewSheetState) -> ViewHost<WhatsNewHarness> {
        let host = sceneHost(
            WhatsNewHarness(state: state),
            size: CGSize(width: 402, height: 874)
        )
        host.pump(0.8)
        return host
    }

    func test_whatsNewView_should_showFirstFeature() {
        // Arrange
        let state = WhatsNewSheetState()

        // Act
        let host = present(state)

        // Assert
        XCTAssertTrue(host.contains("What’s New"))
        XCTAssertTrue(host.contains("A Fresh New Look"))
        XCTAssertTrue(host.contains("Feature 1 of 5"))
        XCTAssertTrue(host.contains("Skip"))
    }

    func test_whatsNewView_should_markReleaseSeen_when_shown() {
        // Arrange
        let state = WhatsNewSheetState()

        // Act
        _ = present(state)

        // Assert
        XCTAssertFalse(WhatsNewRelease.current.isUnseen)
    }

    func test_whatsNewView_should_moveToNextFeature_when_nextTapped() {
        // Arrange
        let state = WhatsNewSheetState()
        let host = present(state)

        // Act
        host.tap("Next")
        host.pump(0.4)

        // Assert
        XCTAssertTrue(host.contains("Feature 2 of 5"))
        XCTAssertTrue(state.isPresented)
    }

    func test_whatsNewView_should_offerGetStartedOnLastFeature() {
        // Arrange
        let state = WhatsNewSheetState()
        let host = present(state)

        // Act
        for _ in 0..<4 {
            host.tap("Next")
            host.pump(0.4)
        }

        // Assert
        XCTAssertTrue(host.contains("Feature 5 of 5"))
        XCTAssertTrue(host.contains("Get Started"))
        XCTAssertFalse(host.contains("Skip"))
    }

    func test_whatsNewView_should_dismiss_when_getStartedTapped() {
        // Arrange
        let state = WhatsNewSheetState()
        let host = present(state)
        for _ in 0..<4 {
            host.tap("Next")
            host.pump(0.4)
        }

        // Act
        host.tap("Get Started")
        host.pump(0.8)

        // Assert
        XCTAssertFalse(state.isPresented)
    }

    func test_whatsNewView_should_dismiss_when_skipTapped() {
        // Arrange
        let state = WhatsNewSheetState()
        let host = present(state)

        // Act
        host.tap("Skip")
        host.pump(0.8)

        // Assert
        XCTAssertFalse(state.isPresented)
    }
}
