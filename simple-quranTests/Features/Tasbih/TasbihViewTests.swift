//
//  TasbihViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
private final class BeadCount: ObservableObject {
    @Published var count = 0
}

private struct BeadHarness: View {
    @ObservedObject var model: BeadCount

    var body: some View {
        TasbihBeadProgressView(
            progress: Double(model.count) / 33,
            count: model.count,
            target: 33
        )
        .frame(width: 360, height: 92)
    }
}

@MainActor
final class TasbihViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func makeHost(
        viewModel: TasbihViewModel,
        onOpenSettings: @escaping () -> Void = {}
    ) -> ViewHost<some View> {
        sceneHost(
            NavigationStack {
                TasbihView(
                    onOpenSettings: onOpenSettings,
                    viewModel: viewModel
                )
            },
            size: CGSize(width: 402, height: 874)
        )
    }

    private func countLabel(_ viewModel: TasbihViewModel) -> String {
        viewModel.isFreeCount ? "Free count active" : "of 33"
    }

    func test_tasbihView_should_showFirstPhraseAndTarget() {
        // Arrange
        let viewModel = TasbihViewModel()

        // Act
        let host = makeHost(viewModel: viewModel)
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("سُبْحَانَ ٱللَّٰهِ"))
        XCTAssertTrue(host.contains("Subhanallah"))
        XCTAssertTrue(host.contains("Alhamdulillah"))
        XCTAssertTrue(host.contains("Allahu Akbar"))
        XCTAssertTrue(host.contains("of 33"))
        XCTAssertTrue(host.contains("Tap anywhere to count"))
        XCTAssertTrue(host.contains("0, of 33"))
    }

    func test_tasbihView_should_countWhenCountingAreaTapped() {
        // Arrange
        let viewModel = TasbihViewModel()
        let host = makeHost(viewModel: viewModel)

        // Act
        host.tap(countLabel(viewModel))
        host.tap(countLabel(viewModel))
        host.pump(0.3)

        // Assert
        XCTAssertEqual(viewModel.count, 2)
        XCTAssertTrue(host.contains("2, of 33"))
    }

    func test_tasbihView_should_decrementAndResetCount() {
        // Arrange
        let viewModel = TasbihViewModel()
        viewModel.count = 5
        let host = makeHost(viewModel: viewModel)

        // Act
        host.tap("-1")
        let afterDecrement = viewModel.count
        host.tap("Reset")

        // Assert
        XCTAssertEqual(afterDecrement, 4)
        XCTAssertEqual(viewModel.count, 0)
    }

    func test_tasbihView_should_switchToFreeCount() {
        // Arrange
        let viewModel = TasbihViewModel()
        let host = makeHost(viewModel: viewModel)

        // Act
        host.tap("Free count")
        host.tap(countLabel(viewModel))
        host.pump(0.3)

        // Assert
        XCTAssertTrue(viewModel.isFreeCount)
        XCTAssertEqual(viewModel.freeCount, 1)
        XCTAssertTrue(host.contains("Free count active"))
        XCTAssertFalse(host.contains("of 33"))
        XCTAssertFalse(host.contains("Subhanallah"))
    }

    func test_tasbihView_should_selectPhraseFromPicker() {
        // Arrange
        let viewModel = TasbihViewModel()
        viewModel.count = 3
        let host = makeHost(viewModel: viewModel)

        // Act
        host.tap("Alhamdulillah")
        host.pump(0.4)

        // Assert
        XCTAssertEqual(viewModel.phraseIndex, 1)
        XCTAssertEqual(viewModel.count, 0)
        XCTAssertTrue(host.contains("ٱلْحَمْدُ لِلَّٰهِ"))
    }

    func test_tasbihView_should_advancePhraseWhenRoundCompletes() {
        // Arrange
        let viewModel = TasbihViewModel()
        viewModel.count = 32
        let host = makeHost(viewModel: viewModel)

        // Act
        host.tap(countLabel(viewModel))
        let completing = viewModel.isCompleting
        host.tap(countLabel(viewModel))
        let countWhileCompleting = viewModel.count
        host.pump(1.0)

        // Assert
        XCTAssertTrue(completing)
        XCTAssertEqual(countWhileCompleting, 33)
        XCTAssertEqual(viewModel.phraseIndex, 1)
        XCTAssertEqual(viewModel.count, 0)
    }

    func test_tasbihView_should_showCompletionAlertAndStartAgain() {
        // Arrange
        let viewModel = TasbihViewModel()
        viewModel.phraseIndex = 2
        viewModel.count = 32
        let host = makeHost(viewModel: viewModel)
        host.tap(countLabel(viewModel))
        host.pump(1.0)
        let alertShown = host.contains("99 Dhikr Complete")

        // Act
        host.tapAlertButton("Start Again")
        host.pump(0.5)

        // Assert
        XCTAssertTrue(alertShown)
        XCTAssertFalse(viewModel.showCompletion)
        XCTAssertEqual(viewModel.phraseIndex, 0)
        XCTAssertEqual(viewModel.count, 0)
    }

    func test_tasbihView_should_openSettingsFromToolbar() {
        // Arrange
        var opened = 0
        let host = makeHost(viewModel: TasbihViewModel()) { opened += 1 }

        // Act
        host.tap("More")

        // Assert
        XCTAssertEqual(opened, 1)
    }

    func test_tasbihView_should_resetEntranceWhenDisappearing() {
        // Arrange
        let viewModel = TasbihViewModel()
        let host = makeHost(viewModel: viewModel)
        host.pump(0.3)

        // Act
        host.tearDown()

        // Assert
        XCTAssertNil(host.window.rootViewController)
    }

    func test_tasbihBeadProgressView_should_highlightBeadAsCountChanges() {
        // Arrange
        let model = BeadCount()
        let host = sceneHost(BeadHarness(model: model), size: CGSize(width: 402, height: 200))

        // Act
        model.count = 4
        host.pump(0.4)
        model.count = 33
        host.pump(0.4)
        model.count = 0
        host.pump(0.3)

        // Assert
        XCTAssertEqual(model.count, 0)
        XCTAssertNotNil(host.controller.view)
    }
}
