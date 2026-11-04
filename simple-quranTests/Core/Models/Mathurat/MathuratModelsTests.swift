//
//  MathuratModelsTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class MathuratModelsTests: XCTestCase {
    private let calendar = TrackerDayKey.calendar

    private func date(hour: Int, minute: Int = 0) -> Date {
        calendar.date(
            byAdding: .minute,
            value: hour * 60 + minute,
            to: calendar.startOfDay(for: TestClock.date(year: 2026, month: 11, day: 4))
        )!
    }

    func test_currentTime_should_switchToEveningAtThreePM() {
        // Arrange
        let beforeThree = date(hour: 14, minute: 59)
        let atThree = date(hour: 15)
        let afterMidnight = date(hour: 0, minute: 30)

        // Act
        let times = [beforeThree, atThree, afterMidnight].map {
            MathuratTime.current(at: $0, calendar: calendar)
        }

        // Assert
        XCTAssertEqual(times, [.morning, .evening, .morning])
    }

    func test_nextChange_should_beThreePMInMorningAndMidnightInEvening() {
        // Arrange
        let morning = date(hour: 9)
        let evening = date(hour: 20)

        // Act
        let fromMorning = MathuratTime.nextChange(after: morning, calendar: calendar)
        let fromEvening = MathuratTime.nextChange(after: evening, calendar: calendar)

        // Assert
        XCTAssertEqual(fromMorning, date(hour: 15))
        XCTAssertEqual(fromEvening, date(hour: 24))
    }

    func test_time_should_exposeKeysAndIcons() {
        // Arrange
        let times = MathuratTime.allCases

        // Act
        let titleKeys = times.map(\.titleKey)
        let labelKeys = times.map(\.labelKey)
        let icons = times.map(\.icon)

        // Assert
        XCTAssertEqual(titleKeys, ["mathurat_time_morning", "mathurat_time_evening"])
        XCTAssertEqual(labelKeys, ["mathurat_label_morning", "mathurat_label_evening"])
        XCTAssertEqual(icons, ["sunrise.fill", "moon.stars.fill"])
    }

    func test_reading_should_includeMatchingSessions() {
        // Arrange
        let readings: [MathuratEntry.Reading] = [.morning, .evening, .both]

        // Act
        let morning = readings.map { $0.includes(.morning) }
        let evening = readings.map { $0.includes(.evening) }

        // Assert
        XCTAssertEqual(morning, [true, false, true])
        XCTAssertEqual(evening, [false, true, true])
    }

    func test_decoding_should_orderFilterAndMapEntries() throws {
        // Arrange
        let json = #"""
        {"entries":[
          {"id":14,"order":13,"title":"","repeat":3,"time":"evening","arabic":"أمسينا","translation":"(Petang)"},
          {"id":2,"order":2,"title":"Al Fatihah (1-7)","repeat":1,"time":"both","arabic":"بسم الله","translation":"Dengan nama Allah"},
          {"id":13,"order":13,"title":"","repeat":3,"time":"morning","arabic":"أصبحنا","translation":"(Pagi)"},
          {"id":1,"order":1,"title":"","repeat":0,"time":"both","arabic":"أعوذ","translation":"Aku berlindung"}
        ]}
        """#
        let file = try JSONDecoder().decode(MathuratFileDTO.self, from: Data(json.utf8))

        // Act
        let morning = file.entries(for: .morning)
        let evening = file.entries(for: .evening)

        // Assert
        XCTAssertEqual(morning.map(\.id), [1, 2, 13])
        XCTAssertEqual(evening.map(\.id), [1, 2, 14])
        XCTAssertEqual(morning.map(\.order), [1, 2, 13])
        XCTAssertEqual(evening.map(\.order), [1, 2, 13])
        XCTAssertNil(morning[0].title)
        XCTAssertEqual(morning[0].repeatCount, 1)
        XCTAssertEqual(morning[1].title, "Al Fatihah (1-7)")
        XCTAssertEqual(morning[2].reading, .morning)
        XCTAssertEqual(morning[2].repeatCount, 3)
    }
}
