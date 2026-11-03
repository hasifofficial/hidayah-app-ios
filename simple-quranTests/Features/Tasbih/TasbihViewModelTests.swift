//
//  TasbihViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TasbihViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    private func increment(_ vm: TasbihViewModel, times: Int) {
        for _ in 0..<times {
            vm.increment()
        }
    }

    func test_init_should_startAtFirstPhraseWithZeroCount() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = TasbihViewModel()

        // Assert
        XCTAssertEqual(vm.target, 33)
        XCTAssertEqual(vm.phrases.count, 3)
        XCTAssertEqual(vm.currentPhrase.nameKey, "tasbih_phrase_1_title")
        XCTAssertEqual(vm.displayedCount, 0)
        XCTAssertEqual(vm.progress, 0)
        XCTAssertFalse(vm.canDecrement)
    }

    func test_increment_should_advanceCountAndProgress() {
        // Arrange
        let vm = TasbihViewModel()

        // Act
        increment(vm, times: 11)

        // Assert
        XCTAssertEqual(vm.count, 11)
        XCTAssertEqual(vm.displayedCount, 11)
        XCTAssertEqual(vm.progress, 11.0 / 33.0, accuracy: 0.0001)
        XCTAssertTrue(vm.canDecrement)
    }

    func test_increment_should_countFreelyWithoutTargetInFreeMode() {
        // Arrange
        let vm = TasbihViewModel()
        vm.toggleFreeCount()

        // Act
        increment(vm, times: 40)

        // Assert
        XCTAssertTrue(vm.isFreeCount)
        XCTAssertEqual(vm.freeCount, 40)
        XCTAssertEqual(vm.displayedCount, 40)
        XCTAssertEqual(vm.count, 0)
        XCTAssertFalse(vm.isCompleting)
    }

    func test_toggleFreeCount_should_switchDisplayedCounter() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 3)
        vm.toggleFreeCount()
        increment(vm, times: 5)

        // Act
        vm.toggleFreeCount()

        // Assert
        XCTAssertFalse(vm.isFreeCount)
        XCTAssertEqual(vm.displayedCount, 3)
        XCTAssertEqual(vm.freeCount, 5)
    }

    func test_increment_should_moveToNextPhraseAfterReachingTarget() async {
        // Arrange
        let vm = TasbihViewModel()

        // Act
        increment(vm, times: 33)
        let completingAtTarget = vm.isCompleting
        let progressAtTarget = vm.progress
        await waitUntil(timeout: 3) { !vm.isCompleting }

        // Assert
        XCTAssertTrue(completingAtTarget)
        XCTAssertEqual(progressAtTarget, 1)
        XCTAssertEqual(vm.phraseIndex, 1)
        XCTAssertEqual(vm.count, 0)
        XCTAssertEqual(vm.currentPhrase.nameKey, "tasbih_phrase_2_title")
        XCTAssertFalse(vm.showCompletion)
    }

    func test_increment_should_beIgnoredWhileCompletingRound() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 33)

        // Act
        vm.increment()

        // Assert
        XCTAssertEqual(vm.count, 33)
        XCTAssertFalse(vm.canDecrement)
    }

    func test_increment_should_showCompletionAfterLastPhrase() async {
        // Arrange
        let vm = TasbihViewModel()
        vm.phraseIndex = 2

        // Act
        increment(vm, times: 33)
        await waitUntil(timeout: 3) { vm.showCompletion }

        // Assert
        XCTAssertTrue(vm.showCompletion)
        XCTAssertTrue(vm.isCompleting)
        XCTAssertEqual(vm.phraseIndex, 2)
    }

    func test_decrement_should_lowerTargetCount() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 2)

        // Act
        vm.decrement()

        // Assert
        XCTAssertEqual(vm.count, 1)
    }

    func test_decrement_should_lowerFreeCountInFreeMode() {
        // Arrange
        let vm = TasbihViewModel()
        vm.toggleFreeCount()
        increment(vm, times: 2)

        // Act
        vm.decrement()

        // Assert
        XCTAssertEqual(vm.freeCount, 1)
        XCTAssertEqual(vm.count, 0)
    }

    func test_decrement_should_notGoBelowZero() {
        // Arrange
        let vm = TasbihViewModel()

        // Act
        vm.decrement()

        // Assert
        XCTAssertEqual(vm.count, 0)
    }

    func test_selectPhrase_should_switchPhraseAndResetCount() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 5)

        // Act
        vm.selectPhrase(2)

        // Assert
        XCTAssertEqual(vm.phraseIndex, 2)
        XCTAssertEqual(vm.count, 0)
        XCTAssertEqual(vm.currentPhrase.nameKey, "tasbih_phrase_3_title")
    }

    func test_selectPhrase_should_keepCountWhenSelectingCurrentPhrase() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 5)

        // Act
        vm.selectPhrase(0)

        // Assert
        XCTAssertEqual(vm.count, 5)
    }

    func test_selectPhrase_should_beIgnoredWhileCompleting() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 33)

        // Act
        vm.selectPhrase(2)

        // Assert
        XCTAssertEqual(vm.phraseIndex, 0)
    }

    func test_resetCurrent_should_resetOnlyTargetCount() {
        // Arrange
        let vm = TasbihViewModel()
        vm.freeCount = 7
        increment(vm, times: 4)

        // Act
        vm.resetCurrent()

        // Assert
        XCTAssertEqual(vm.count, 0)
        XCTAssertEqual(vm.freeCount, 7)
    }

    func test_resetCurrent_should_resetOnlyFreeCountInFreeMode() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 4)
        vm.toggleFreeCount()
        increment(vm, times: 6)

        // Act
        vm.resetCurrent()

        // Assert
        XCTAssertEqual(vm.freeCount, 0)
        XCTAssertEqual(vm.count, 4)
    }

    func test_resetCurrent_should_beIgnoredWhileCompleting() {
        // Arrange
        let vm = TasbihViewModel()
        increment(vm, times: 33)

        // Act
        vm.resetCurrent()

        // Assert
        XCTAssertEqual(vm.count, 33)
    }

    func test_startAgain_should_resetEverything() async {
        // Arrange
        let vm = TasbihViewModel()
        vm.phraseIndex = 2
        vm.freeCount = 9
        increment(vm, times: 33)
        await waitUntil(timeout: 3) { vm.showCompletion }
        vm.isFreeCount = true

        // Act
        vm.startAgain()

        // Assert
        XCTAssertEqual(vm.count, 0)
        XCTAssertEqual(vm.freeCount, 0)
        XCTAssertEqual(vm.phraseIndex, 0)
        XCTAssertFalse(vm.isFreeCount)
        XCTAssertFalse(vm.showCompletion)
        XCTAssertFalse(vm.isCompleting)
    }

    func test_progress_should_capAtOne() {
        // Arrange
        let vm = TasbihViewModel()

        // Act
        vm.count = 50

        // Assert
        XCTAssertEqual(vm.progress, 1)
    }
}
