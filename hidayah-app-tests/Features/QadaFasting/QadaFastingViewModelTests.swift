//
//  QadaFastingViewModelTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

@MainActor
final class QadaFastingViewModelTests: XCTestCase {
    private var clock: TestClock!
    private var manager: QadaFastingManager!
    private var sut: QadaFastingViewModel!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        clock = TestClock(hijriDate(1447, 10, 15))
        manager = makeQadaManager(clock: clock)
        sut = QadaFastingViewModel(manager: manager)
    }

    override func tearDown() async throws {
        sut = nil
        manager = nil
        clock = nil
        resetStorage()
        try await super.tearDown()
    }

    func test_isEmpty_should_beTrue_when_noYearsAdded() {
        // Arrange & Act
        let isEmpty = sut.isEmpty

        // Assert
        XCTAssertTrue(isEmpty)
        XCTAssertFalse(sut.isAllMadeUp)
        XCTAssertFalse(sut.canLogFast)
    }

    func test_summaryText_should_describeProgress() {
        // Arrange
        sut.saveYear(1447, owedDays: 4)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.summaryText, "1 of 4 made up")
        XCTAssertEqual(sut.remainingCount, "3")
    }

    func test_logFast_should_returnErrorForDuplicateDay() {
        // Arrange
        sut.saveYear(1447, owedDays: 4)
        _ = sut.logFast(on: clock.now)

        // Act
        let error = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(error, "You've already logged a fast on this day.")
    }

    func test_logFast_should_returnErrorForFutureDay() {
        // Arrange
        sut.saveYear(1447, owedDays: 4)

        // Act
        let error = sut.logFast(on: clock.now.addingTimeInterval(86_400 * 3))

        // Assert
        XCTAssertEqual(error, "You can't log a fast for a day that hasn't come yet.")
    }

    func test_confirmFastRemoval_should_deletePendingFast() {
        // Arrange
        sut.saveYear(1447, owedDays: 4)
        _ = sut.logFast(on: clock.now)
        sut.fastPendingRemoval = sut.ledger.fasts.first

        // Act
        sut.confirmFastRemoval()

        // Assert
        XCTAssertTrue(sut.ledger.fasts.isEmpty)
        XCTAssertNil(sut.fastPendingRemoval)
    }

    func test_deadlineText_should_nameNextRamadan() {
        // Arrange
        let ramadan = hijriDate(1448, 9, 1)
        clock.now = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: ramadan)!

        // Act
        let deadline = sut.deadline

        // Assert
        XCTAssertEqual(deadline, .init(label: "Ramadan 1448 begins", countdown: "tomorrow"))
    }

    func test_deadline_should_countDays_when_ramadanIsWeeksAway() {
        // Arrange
        let ramadan = hijriDate(1448, 9, 1)
        clock.now = Calendar(identifier: .gregorian).date(byAdding: .day, value: -72, to: ramadan)!

        // Act
        let deadline = sut.deadline

        // Assert
        XCTAssertEqual(deadline?.countdown, "in 72 days")
    }

    func test_formatting_should_useLocalizedText() {
        // Arrange
        let year = QadaYear(hijriYear: 1446, owedDays: 5, madeUpDays: 2)

        // Act & Assert
        XCTAssertEqual(sut.yearTitle(1446), "Ramadan 1446")
        XCTAssertEqual(sut.yearDetail(year), "2 of 5 made up")
        XCTAssertEqual(sut.yearDetail(QadaYear(hijriYear: 1446, owedDays: 2, madeUpDays: 2)), "Complete")
        XCTAssertEqual(QadaFastingViewModel.daysText(1), "1 day")
        XCTAssertEqual(QadaFastingViewModel.daysText(6), "6 days")
    }

    func test_addableYears_should_excludeTrackedYears() {
        // Arrange
        sut.saveYear(1447, owedDays: 2)

        // Act
        let years = sut.addableYears

        // Assert
        XCTAssertEqual(years.first, 1446)
        XCTAssertFalse(years.contains(1447))
        XCTAssertTrue(sut.canAddYear)
    }

    func test_logFast_should_celebrateWithToast() {
        // Arrange
        sut.saveYear(1447, owedDays: 4)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.celebration, 1)
        XCTAssertEqual(sut.toast, "Taqabbal Allahu minna wa minkum")
    }

    func test_logFast_should_celebrateCompletion_when_lastDayIsMadeUp() {
        // Arrange
        sut.saveYear(1447, owedDays: 1)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.toast, "Every fast made up. Alhamdulillah!")
        XCTAssertEqual(sut.heroSummary, "All made up, alhamdulillah")
        XCTAssertEqual(sut.moonPhase, 1)
    }

    func test_logFast_should_notCelebrate_when_refused() {
        // Arrange
        sut.saveYear(1447, owedDays: 2)

        // Act
        _ = sut.logFast(on: clock.now.addingTimeInterval(86_400 * 3))

        // Assert
        XCTAssertEqual(sut.celebration, 0)
        XCTAssertNil(sut.toast)
    }

    func test_moonPhase_should_followProgress() {
        // Arrange
        sut.saveYear(1446, owedDays: 2)
        sut.saveYear(1447, owedDays: 2)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.moonPhase, 0.25, accuracy: 0.0001)
        XCTAssertEqual(sut.nextYear, 1446)
    }

    func test_remainingLabel_should_beSingular_when_oneDayLeft() {
        // Arrange
        sut.saveYear(1447, owedDays: 2)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.remainingLabel, "day left")
    }

    func test_fastSections_should_groupByMonthNewestFirst() {
        // Arrange
        let calendar = Calendar.current
        clock.now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 3, hour: 12))!
        sut.saveYear(1447, owedDays: 5)
        let novemberFirst = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 12))!
        let octoberEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 30, hour: 12))!

        // Act
        _ = sut.logFast(on: octoberEnd)
        _ = sut.logFast(on: novemberFirst)
        _ = sut.logFast(on: clock.now)

        // Assert
        let sections = sut.fastSections
        XCTAssertEqual(sections.map(\.title), ["November 2026", "October 2026"])
        XCTAssertEqual(sections.map(\.fasts.count), [2, 1])
        XCTAssertEqual(sut.dayBadge(sections[0].fasts[0]).day, "3")
        XCTAssertEqual(sut.dayBadge(sections[0].fasts[0]).weekday, "Tue")
    }

    func test_showsAddMenu_should_hide_when_ledgerIsEmpty() {
        // Arrange & Act
        let shows = sut.showsAddMenu

        // Assert
        XCTAssertFalse(shows)
    }

    func test_showsAddMenu_should_offerBothActions_when_daysAreOwed() {
        // Arrange
        sut.saveYear(1447, owedDays: 2)

        // Act
        let shows = sut.showsAddMenu

        // Assert
        XCTAssertTrue(shows)
        XCTAssertTrue(sut.canLogFast)
        XCTAssertTrue(sut.canAddYear)
    }

    func test_canLogFast_should_beFalse_when_everythingIsMadeUp() {
        // Arrange
        sut.saveYear(1447, owedDays: 1)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertFalse(sut.canLogFast)
        XCTAssertTrue(sut.showsAddMenu)
    }

    func test_suggestedLogDate_should_beToday_until_todayIsLogged() {
        // Arrange
        sut.saveYear(1447, owedDays: 3)
        let today = utcRamadanCalendar.startOfDay(clock.now)
        XCTAssertEqual(sut.suggestedLogDate, today)

        // Act
        _ = sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.suggestedLogDate, Calendar.current.date(byAdding: .day, value: -1, to: today))
    }
}
