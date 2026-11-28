//
//  RamadanCalendarTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class RamadanCalendarTests: XCTestCase {
    private let sut = RamadanCalendar(timeZone: TimeZone(identifier: "UTC")!)

    func test_latestRamadanYear_should_beLastYear_when_ramadanHasNotStarted() {
        // Arrange
        let date = hijriDate(1447, 8, 15)

        // Act
        let year = sut.latestRamadanYear(asOf: date)

        // Assert
        XCTAssertEqual(year, 1446)
    }

    func test_latestRamadanYear_should_beThisYear_when_ramadanHasStarted() {
        // Arrange
        let date = hijriDate(1447, 9, 1)

        // Act
        let year = sut.latestRamadanYear(asOf: date)

        // Assert
        XCTAssertEqual(year, 1447)
        XCTAssertEqual(sut.latestRamadanYear(asOf: hijriDate(1447, 12, 20)), 1447)
    }

    func test_nextRamadanStart_should_beNextYearsRamadan_when_duringRamadan() {
        // Arrange
        let date = hijriDate(1447, 9, 10)

        // Act
        let start = sut.nextRamadanStart(after: date)

        // Assert
        XCTAssertEqual(start, sut.startOfDay(hijriDate(1448, 9, 1)))
    }

    func test_daysUntilNextRamadan_should_countWholeDays() {
        // Arrange
        let ramadan = hijriDate(1448, 9, 1)
        let date = Calendar(identifier: .gregorian).date(byAdding: .day, value: -10, to: ramadan)!

        // Act
        let days = sut.daysUntilNextRamadan(from: date)

        // Assert
        XCTAssertEqual(days, 10)
    }

    func test_isSameDay_should_ignoreTimeOfDay() {
        // Arrange
        let morning = Date(timeIntervalSince1970: 3_600)
        let evening = Date(timeIntervalSince1970: 80_000)

        // Act
        let same = sut.isSameDay(morning, evening)

        // Assert
        XCTAssertTrue(same)
        XCTAssertFalse(sut.isSameDay(morning, evening.addingTimeInterval(86_400)))
    }
}
