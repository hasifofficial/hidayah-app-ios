//
//  QadaLedgerTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class QadaLedgerTests: XCTestCase {
    func test_init_should_sortYearsOldestFirstAndFastsNewestFirst() {
        // Arrange
        let older = QadaFast(date: Date(timeIntervalSince1970: 100), hijriYear: 1445)
        let newer = QadaFast(date: Date(timeIntervalSince1970: 200), hijriYear: 1445)

        // Act
        let ledger = QadaLedger(owedDays: [1446: 3, 1445: 4], fasts: [older, newer])

        // Assert
        XCTAssertEqual(ledger.years.map(\.hijriYear), [1445, 1446])
        XCTAssertEqual(ledger.fasts, [newer, older])
    }

    func test_init_should_countFastsPerYear() {
        // Arrange
        let fasts = [
            QadaFast(date: Date(), hijriYear: 1445),
            QadaFast(date: Date(), hijriYear: 1445),
            QadaFast(date: Date(), hijriYear: 1446)
        ]

        // Act
        let ledger = QadaLedger(owedDays: [1445: 2, 1446: 6], fasts: fasts)

        // Assert
        XCTAssertEqual(ledger.years.map(\.madeUpDays), [2, 1])
        XCTAssertEqual(ledger.years.map(\.remainingDays), [0, 5])
        XCTAssertEqual(ledger.years.map(\.isComplete), [true, false])
    }

    func test_totals_should_sumAcrossYears() {
        // Arrange
        let fasts = [QadaFast(date: Date(), hijriYear: 1445)]

        // Act
        let ledger = QadaLedger(owedDays: [1445: 2, 1446: 6], fasts: fasts)

        // Assert
        XCTAssertEqual(ledger.totalOwed, 8)
        XCTAssertEqual(ledger.totalMadeUp, 1)
        XCTAssertEqual(ledger.totalRemaining, 7)
        XCTAssertEqual(ledger.progress, 0.125, accuracy: 0.0001)
    }

    func test_yearForNextFast_should_pickOldestYearStillOwed() {
        // Arrange
        let fasts = [QadaFast(date: Date(), hijriYear: 1444)]

        // Act
        let ledger = QadaLedger(owedDays: [1444: 1, 1445: 3, 1446: 2], fasts: fasts)

        // Assert
        XCTAssertEqual(ledger.yearForNextFast, 1445)
    }

    func test_yearForNextFast_should_beNilWhenEverythingIsMadeUp() {
        // Arrange
        let fasts = [QadaFast(date: Date(), hijriYear: 1445)]

        // Act
        let ledger = QadaLedger(owedDays: [1445: 1], fasts: fasts)

        // Assert
        XCTAssertNil(ledger.yearForNextFast)
        XCTAssertEqual(ledger.progress, 1)
    }

    func test_empty_should_haveNoProgress() {
        // Arrange
        let ledger = QadaLedger.empty

        // Act
        let progress = ledger.progress

        // Assert
        XCTAssertEqual(progress, 0)
        XCTAssertEqual(ledger.totalRemaining, 0)
        XCTAssertEqual(QadaYear(hijriYear: 1445, owedDays: 0, madeUpDays: 0).progress, 0)
    }
}
