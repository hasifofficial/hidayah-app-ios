//
//  QadaFastingManagerTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

@MainActor
final class QadaFastingManagerTests: XCTestCase {
    private var store: HidayahStore!
    private var clock: TestClock!
    private var sut: QadaFastingManager!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        store = makeInMemoryStore()
        // 15 Shawwal 1447: Ramadan 1447 has just ended.
        clock = TestClock(hijriDate(1447, 10, 15))
        sut = makeQadaManager(store: store, clock: clock)
    }

    override func tearDown() async throws {
        sut = nil
        clock = nil
        store = nil
        resetStorage()
        try await super.tearDown()
    }

    // MARK: - Years

    func test_setOwedDays_should_addYearAndPersistIt() {
        // Arrange
        let year = 1447

        // Act
        sut.setOwedDays(6, for: year)

        // Assert
        XCTAssertEqual(sut.ledger.years.map(\.owedDays), [6])
        XCTAssertEqual(store.loadQadaLedger().years.map(\.hijriYear), [1447])
    }

    func test_setOwedDays_should_capAtThirtyDays() {
        // Arrange
        let year = 1447

        // Act
        sut.setOwedDays(45, for: year)

        // Assert
        XCTAssertEqual(sut.ledger.year(year)?.owedDays, 30)
    }

    func test_setOwedDays_should_notGoBelowDaysAlreadyMadeUp() {
        // Arrange
        sut.setOwedDays(5, for: 1447)
        sut.logFast(on: clock.now)
        sut.logFast(on: clock.now.addingTimeInterval(-86_400))

        // Act
        sut.setOwedDays(1, for: 1447)

        // Assert
        XCTAssertEqual(sut.ledger.year(1447)?.owedDays, 2)
    }

    func test_setOwedDays_should_removeYear_when_setToZeroWithNoFasts() {
        // Arrange
        sut.setOwedDays(3, for: 1447)

        // Act
        sut.setOwedDays(0, for: 1447)

        // Assert
        XCTAssertTrue(sut.ledger.years.isEmpty)
    }

    func test_removeYear_should_deleteItsFasts() {
        // Arrange
        sut.setOwedDays(3, for: 1446)
        sut.setOwedDays(3, for: 1447)
        sut.logFast(on: clock.now)

        // Act
        sut.removeYear(1446)

        // Assert
        XCTAssertEqual(sut.ledger.years.map(\.hijriYear), [1447])
        XCTAssertTrue(sut.ledger.fasts.isEmpty)
    }

    func test_availableYears_should_leaveOutTrackedYears() {
        // Arrange
        sut.setOwedDays(2, for: 1446)

        // Act
        let years = sut.availableYears(lookingBack: 4)

        // Assert
        XCTAssertEqual(years, [1447, 1445, 1444])
    }

    func test_latestRamadanYear_should_followTheClock() {
        // Arrange
        clock.now = hijriDate(1448, 6, 8)

        // Act
        let latest = sut.latestRamadanYear

        // Assert
        XCTAssertEqual(latest, 1447)
        XCTAssertEqual(sut.nextRamadanYear, 1448)
        XCTAssertNotNil(sut.daysUntilNextRamadan)
    }

    // MARK: - Fasts

    func test_logFast_should_countAgainstOldestYearOwed() {
        // Arrange
        sut.setOwedDays(1, for: 1446)
        sut.setOwedDays(4, for: 1447)

        // Act
        let first = sut.logFast(on: clock.now)
        let second = sut.logFast(on: clock.now.addingTimeInterval(-86_400))

        // Assert
        XCTAssertEqual(first, .logged(hijriYear: 1446))
        XCTAssertEqual(second, .logged(hijriYear: 1447))
        XCTAssertEqual(sut.ledger.totalRemaining, 3)
        XCTAssertTrue(sut.hasLoggedToday)
    }

    func test_logFast_should_refuseSecondFastOnSameDay() {
        // Arrange
        sut.setOwedDays(4, for: 1447)
        sut.logFast(on: clock.now)

        // Act
        let result = sut.logFast(on: clock.now.addingTimeInterval(3_600))

        // Assert
        XCTAssertEqual(result, .alreadyLogged)
        XCTAssertEqual(sut.ledger.fasts.count, 1)
    }

    func test_logFast_should_refuseFutureDay() {
        // Arrange
        sut.setOwedDays(4, for: 1447)

        // Act
        let result = sut.logFast(on: clock.now.addingTimeInterval(86_400 * 2))

        // Assert
        XCTAssertEqual(result, .inFuture)
        XCTAssertTrue(sut.ledger.fasts.isEmpty)
    }

    func test_logFast_should_refuse_when_nothingIsOwed() {
        // Arrange
        sut.setOwedDays(1, for: 1447)
        sut.logFast(on: clock.now)

        // Act
        let result = sut.logFast(on: clock.now.addingTimeInterval(-86_400))

        // Assert
        XCTAssertEqual(result, .nothingOwed)
    }

    func test_logFast_should_storeStartOfDay() {
        // Arrange
        sut.setOwedDays(1, for: 1447)

        // Act
        sut.logFast(on: clock.now)

        // Assert
        XCTAssertEqual(sut.ledger.fasts.first?.date, utcRamadanCalendar.startOfDay(clock.now))
    }

    func test_deleteFast_should_giveTheDayBack() {
        // Arrange
        sut.setOwedDays(2, for: 1447)
        sut.logFast(on: clock.now)
        let id = sut.ledger.fasts[0].id

        // Act
        sut.deleteFast(id: id)

        // Assert
        XCTAssertEqual(sut.ledger.totalRemaining, 2)
        XCTAssertFalse(sut.hasLoggedToday)
    }

    func test_init_should_loadSavedLedger() {
        // Arrange
        sut.setOwedDays(3, for: 1447)
        sut.logFast(on: clock.now)

        // Act
        let reloaded = makeQadaManager(store: store, clock: clock)

        // Assert
        XCTAssertEqual(reloaded.ledger, sut.ledger)
    }

    func test_resetTracker_should_keepQadaLedger() {
        // Arrange
        sut.setOwedDays(3, for: 1447)

        // Act
        store.resetTracker()

        // Assert
        XCTAssertEqual(store.loadQadaLedger().totalOwed, 3)
    }
}
