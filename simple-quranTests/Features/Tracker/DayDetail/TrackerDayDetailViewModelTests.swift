//
//  TrackerDayDetailViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TrackerDayDetailViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_date_should_parseDayKey() {
        // Arrange
        let vm = TrackerDayDetailViewModel(
            taskManager: VMFixtures.makeTaskManager(),
            dayKey: "2026-11-03",
            record: nil
        )

        // Act
        let date = vm.date

        // Assert
        XCTAssertEqual(date.map { TrackerDayKey.key(for: $0) }, "2026-11-03")
    }

    func test_gregorianDateText_should_formatDayMonthYear() {
        // Arrange
        let vm = TrackerDayDetailViewModel(
            taskManager: VMFixtures.makeTaskManager(),
            dayKey: "2026-11-03",
            record: nil
        )
        let november = TrackerDayKey.calendar.monthSymbols[10]

        // Act
        let text = vm.gregorianDateText

        // Assert
        XCTAssertTrue(text.hasPrefix("3 "), text)
        XCTAssertTrue(text.contains(november), text)
        XCTAssertTrue(text.hasSuffix("2026"), text)
    }

    func test_islamicDateText_should_formatHijriDateInEnglish() {
        // Arrange
        let vm = TrackerDayDetailViewModel(
            taskManager: VMFixtures.makeTaskManager(),
            dayKey: "2026-11-03",
            record: nil
        )

        // Act
        let text = vm.islamicDateText

        // Assert
        XCTAssertTrue(text.contains("Jumada"), text)
        XCTAssertTrue(text.hasSuffix("1448"), text)
    }

    func test_dateTexts_should_fallBackForMalformedDayKey() {
        // Arrange
        let vm = TrackerDayDetailViewModel(
            taskManager: VMFixtures.makeTaskManager(),
            dayKey: "not-a-day",
            record: nil
        )

        // Act
        let gregorian = vm.gregorianDateText
        let islamic = vm.islamicDateText

        // Assert
        XCTAssertNil(vm.date)
        XCTAssertEqual(gregorian, "not-a-day")
        XCTAssertEqual(islamic, "")
    }

    func test_groupedTasks_should_beEmptyWithoutRecord() {
        // Arrange
        let vm = TrackerDayDetailViewModel(
            taskManager: VMFixtures.makeTaskManager(),
            dayKey: "2026-11-03",
            record: nil
        )

        // Act
        let groups = vm.groupedTasks

        // Assert
        XCTAssertTrue(groups.isEmpty)
    }

    func test_groupedTasks_should_followCategoryOrderThenNameForUnknownCategories() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager()
        taskManager.addCustomCategory(name: "Mine", icon: "star")
        let mine = simple_quran.Category.custom(taskManager.customCategories[0])
        let zeta = simple_quran.Category.custom(CustomCategory(name: "Zeta"))
        let alpha = simple_quran.Category.custom(CustomCategory(name: "Alpha"))
        let record = TrackerDayRecord(
            dayKey: "2026-11-03",
            tasks: [
                VMFixtures.snapshot("Fajr prayer", category: .default(.fajr), isCompleted: true),
                VMFixtures.snapshot("Zeta task", category: zeta, isCompleted: false),
                VMFixtures.snapshot("Mine task", category: mine, isCompleted: true),
                VMFixtures.snapshot("Wake do'a", category: .default(.morning), isCompleted: false),
                VMFixtures.snapshot("Alpha task", category: alpha, isCompleted: false),
                VMFixtures.snapshot("Istighfar", category: .default(.fajr), isCompleted: false)
            ]
        )
        let vm = TrackerDayDetailViewModel(
            taskManager: taskManager,
            dayKey: record.dayKey,
            record: record
        )

        // Act
        let groups = vm.groupedTasks

        // Assert
        XCTAssertEqual(groups.map(\.categoryID), [
            simple_quran.Category.default(.morning).id,
            simple_quran.Category.default(.fajr).id,
            mine.id,
            alpha.id,
            zeta.id
        ])
        XCTAssertEqual(groups[1].tasks.map(\.name), ["Fajr prayer", "Istighfar"])
        XCTAssertEqual(vm.record, record)
        XCTAssertEqual(vm.dayKey, "2026-11-03")
    }
}
