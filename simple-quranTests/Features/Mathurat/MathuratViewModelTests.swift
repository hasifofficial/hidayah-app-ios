//
//  MathuratViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class MathuratViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func makeViewModel(
        loader: FakeMathuratLoader = FakeMathuratLoader(),
        clock: TestClock = MathuratFixtures.clock(morning: true)
    ) -> MathuratViewModel {
        MathuratViewModel(
            loader: loader,
            now: { clock.now },
            calendar: TrackerDayKey.calendar
        )
    }

    // MARK: Session

    func test_init_should_pickMorning_when_beforeThreePM() {
        // Arrange
        let clock = MathuratFixtures.clock(morning: true)

        // Act
        let viewModel = makeViewModel(clock: clock)

        // Assert
        XCTAssertEqual(viewModel.time, .morning)
        XCTAssertFalse(viewModel.isLoaded)
    }

    func test_init_should_pickEvening_when_fromThreePM() {
        // Arrange
        let clock = MathuratFixtures.clock(morning: false)

        // Act
        let viewModel = makeViewModel(clock: clock)

        // Assert
        XCTAssertEqual(viewModel.time, .evening)
    }

    func test_refreshTime_should_switchToEveningEntries_when_clockPassesThreePM() {
        // Arrange
        let clock = MathuratFixtures.clock(morning: true)
        let viewModel = makeViewModel(clock: clock)
        viewModel.loadIfNeeded()
        let first = viewModel.entries[0]
        viewModel.increment(first)
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 15)

        // Act
        viewModel.refreshTime()

        // Assert
        XCTAssertEqual(viewModel.time, .evening)
        XCTAssertEqual(viewModel.entries.map(\.id), [1, 2, 14])
        XCTAssertEqual(viewModel.count(for: first), 0)
    }

    func test_refreshTime_should_keepMorningCounts_when_returningToMorning() {
        // Arrange
        let clock = MathuratFixtures.clock(morning: true)
        let viewModel = makeViewModel(clock: clock)
        viewModel.loadIfNeeded()
        let first = viewModel.entries[0]
        viewModel.increment(first)
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 16)
        viewModel.refreshTime()
        clock.now = TestClock.date(year: 2026, month: 11, day: 5, hour: 8)

        // Act
        viewModel.refreshTime()

        // Assert
        XCTAssertEqual(viewModel.time, .morning)
        XCTAssertEqual(viewModel.count(for: first), 1)
    }

    func test_refreshTime_should_doNothing_when_timeOfDayIsUnchanged() {
        // Arrange
        let loader = FakeMathuratLoader()
        let clock = MathuratFixtures.clock(morning: true)
        let viewModel = makeViewModel(loader: loader, clock: clock)
        viewModel.loadIfNeeded()
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 14)

        // Act
        viewModel.refreshTime()

        // Assert
        XCTAssertEqual(viewModel.time, .morning)
        XCTAssertEqual(loader.requests, [.morning])
    }

    func test_secondsUntilTimeChange_should_countDownToThreePM() {
        // Arrange
        let viewModel = makeViewModel(clock: MathuratFixtures.clock(morning: true))

        // Act
        let seconds = viewModel.secondsUntilTimeChange

        // Assert
        XCTAssertEqual(seconds, 5 * 60 * 60, accuracy: 1)
    }

    // MARK: Loading

    func test_loadIfNeeded_should_loadMorningEntriesOnce() {
        // Arrange
        let loader = FakeMathuratLoader()
        let viewModel = makeViewModel(loader: loader)

        // Act
        viewModel.loadIfNeeded()
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertTrue(viewModel.isLoaded)
        XCTAssertEqual(viewModel.entries.map(\.id), [1, 2, 13])
        XCTAssertEqual(loader.requests, [.morning])
        XCTAssertNil(viewModel.loadError)
    }

    func test_refreshTime_should_reuseLoadedEntries_when_switchingBack() {
        // Arrange
        let loader = FakeMathuratLoader()
        let clock = MathuratFixtures.clock(morning: true)
        let viewModel = makeViewModel(loader: loader, clock: clock)
        viewModel.loadIfNeeded()
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 16)
        viewModel.refreshTime()
        clock.now = TestClock.date(year: 2026, month: 11, day: 5, hour: 9)

        // Act
        viewModel.refreshTime()

        // Assert
        XCTAssertEqual(loader.requests, [.morning, .evening])
        XCTAssertEqual(viewModel.entries.map(\.id), [1, 2, 13])
    }

    func test_load_should_exposeError_and_recoverOnRetry() {
        // Arrange
        let loader = FakeMathuratLoader()
        loader.error = MathuratLoadError.missingResource
        let viewModel = makeViewModel(loader: loader)
        viewModel.loadIfNeeded()
        let failed = viewModel.loadError
        loader.error = nil

        // Act
        viewModel.retry()

        // Assert
        XCTAssertEqual(failed, .missingResource)
        XCTAssertNil(viewModel.loadError)
        XCTAssertTrue(viewModel.isLoaded)
        XCTAssertEqual(viewModel.entries.count, 3)
    }

    func test_load_should_reportCorrupt_when_loaderThrowsOtherError() {
        // Arrange
        let loader = FakeMathuratLoader()
        loader.error = URLError(.cannotDecodeContentData)
        let viewModel = makeViewModel(loader: loader)

        // Act
        viewModel.loadIfNeeded()

        // Assert
        XCTAssertEqual(viewModel.loadError, .corrupt)
        XCTAssertFalse(viewModel.isLoaded)
        XCTAssertTrue(viewModel.entries.isEmpty)
    }

    // MARK: Counting

    func test_increment_should_completeAtRepeatCount() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()
        let dua = viewModel.entries[2]

        // Act
        for _ in 0..<3 {
            viewModel.increment(dua)
        }

        // Assert
        XCTAssertEqual(dua.repeatCount, 3)
        XCTAssertEqual(viewModel.count(for: dua), 3)
        XCTAssertTrue(viewModel.isComplete(dua))
    }

    func test_increment_should_resetCount_when_entryIsDone() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()
        let dua = viewModel.entries[2]
        for _ in 0..<3 {
            viewModel.increment(dua)
        }

        // Act
        viewModel.increment(dua)

        // Assert
        XCTAssertEqual(viewModel.count(for: dua), 0)
        XCTAssertFalse(viewModel.isComplete(dua))
    }

    // MARK: Sharing

    func test_shareText_should_includeTextTitleAndDeepLinkByOrder() {
        // Arrange
        let viewModel = makeViewModel()
        let entry = MathuratFixtures.entry(id: 40, order: 2, title: "Al Fatihah (1-7)")

        // Act
        let text = viewModel.shareText(for: entry)

        // Assert
        XCTAssertEqual(
            text,
            "\(entry.arabic)\n\(entry.translation) [Al-Mathurat · Al Fatihah (1-7)]\n\nShared from Hidayah App\nhidayahapp://inAppDeeplink/mathurat/2"
        )
    }

    func test_shareText_should_referToMathurat_when_entryHasNoTitle() {
        // Arrange
        let viewModel = makeViewModel()
        let entry = MathuratFixtures.entry(id: 13)

        // Act
        let text = viewModel.shareText(for: entry)

        // Assert
        XCTAssertTrue(text.contains("[Al-Mathurat]"))
        XCTAssertTrue(text.hasSuffix("hidayahapp://inAppDeeplink/mathurat/13"))
    }

    func test_updateReadFraction_should_followScrollBothWays() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()

        // Act
        viewModel.updateReadFraction(0.45)
        let down = viewModel.progressPercent
        viewModel.updateReadFraction(0.2)

        // Assert
        XCTAssertEqual(down, 45)
        XCTAssertEqual(viewModel.progress, 0.2, accuracy: 0.001)
        XCTAssertEqual(viewModel.progressPercent, 20)
    }

    func test_updateReadFraction_should_clampToZeroAndOne() {
        // Arrange
        let viewModel = makeViewModel()
        viewModel.loadIfNeeded()

        // Act
        viewModel.updateReadFraction(1.4)
        let overscrolled = viewModel.progressPercent
        viewModel.updateReadFraction(-0.3)

        // Assert
        XCTAssertEqual(overscrolled, 100)
        XCTAssertEqual(viewModel.progress, 0)
    }

    func test_updateReadFraction_should_beIgnored_when_nothingIsLoaded() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        viewModel.updateReadFraction(0.5)

        // Assert
        XCTAssertEqual(viewModel.progress, 0)
    }

    func test_readFraction_should_beKeptPerSession() {
        // Arrange
        let clock = MathuratFixtures.clock(morning: true)
        let viewModel = makeViewModel(clock: clock)
        viewModel.loadIfNeeded()
        viewModel.updateReadFraction(0.6)
        clock.now = TestClock.date(year: 2026, month: 11, day: 4, hour: 16)

        // Act
        viewModel.refreshTime()
        let evening = viewModel.progress
        clock.now = TestClock.date(year: 2026, month: 11, day: 5, hour: 9)
        viewModel.refreshTime()

        // Assert
        XCTAssertEqual(evening, 0)
        XCTAssertEqual(viewModel.progress, 0.6, accuracy: 0.001)
    }

    func test_progress_should_beZero_when_nothingIsLoaded() {
        // Arrange
        let viewModel = makeViewModel()

        // Act
        let progress = viewModel.progress

        // Assert
        XCTAssertEqual(progress, 0)
    }

}
