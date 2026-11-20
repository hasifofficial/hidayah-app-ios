//
//  HomeDateFormatterTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class HomeDateFormatterTests: XCTestCase {
    private let utc = TimeZone(identifier: "UTC")!

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    func test_gregorian_should_showWeekdayDayMonthAndYear() {
        // Arrange
        let monday = date(2026, 11, 16)

        // Act
        let text = HomeDateFormatter.gregorian(
            monday,
            locale: Locale(identifier: "en_GB"),
            timeZone: utc
        )

        // Assert
        XCTAssertTrue(text.contains("Monday"), text)
        XCTAssertTrue(text.contains("16 November 2026"), text)
    }

    func test_hijri_should_showHijriYearWithSuffix() {
        // Arrange
        let monday = date(2026, 11, 16)

        // Act
        let text = HomeDateFormatter.hijri(monday, timeZone: utc)

        // Assert
        XCTAssertTrue(text.hasSuffix(" AH"), text)
        XCTAssertTrue(text.contains("1448"), text)
    }
}
