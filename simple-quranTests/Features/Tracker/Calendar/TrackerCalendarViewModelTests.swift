//
//  TrackerCalendarViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TrackerCalendarViewModelTests: XCTestCase {
    private var store: HidayahStore!
    private var calendar: Calendar { TrackerDayKey.calendar }

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        store = makeInMemoryStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    /// October 2026: a perfect day, a partial day, a perfect day with two
    /// tasks, an empty day; plus one September day outside the month.
    private func makeSeededViewModel() -> TrackerCalendarViewModel {
        store.saveDay(VMFixtures.dayRecord("2026-09-30", completed: 4, total: 4))
        store.saveDay(VMFixtures.dayRecord("2026-10-05", completed: 3, total: 3))
        store.saveDay(VMFixtures.dayRecord("2026-10-06", completed: 1, total: 4))
        store.saveDay(VMFixtures.dayRecord("2026-10-20", completed: 2, total: 2))
        store.saveDay(VMFixtures.dayRecord("2026-10-21", completed: 0, total: 5))
        let vm = TrackerCalendarViewModel(
            taskManager: VMFixtures.makeTaskManager(store: store)
        )
        vm.displayedMonth = TestClock.date(year: 2026, month: 10, day: 1, hour: 0)
        return vm
    }

    func test_init_should_displayStartOfCurrentMonth() {
        // Arrange
        let expected = calendar.date(
            from: calendar.dateComponents([.year, .month], from: Date())
        )

        // Act
        let vm = TrackerCalendarViewModel(taskManager: VMFixtures.makeTaskManager(store: store))

        // Assert
        XCTAssertEqual(vm.displayedMonth, expected)
        XCTAssertEqual(vm.calendar.identifier, .gregorian)
    }

    func test_startDayKey_should_comeFromTaskManager() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)

        // Act
        let vm = TrackerCalendarViewModel(taskManager: taskManager)

        // Assert
        XCTAssertEqual(vm.startDayKey, "2026-11-03")
    }

    func test_monthTitle_should_nameDisplayedMonthAndYear() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let title = vm.monthTitle

        // Assert
        XCTAssertTrue(title.contains("2026"))
        XCTAssertTrue(title.contains(calendar.standaloneMonthSymbols[9]) || title.contains(calendar.monthSymbols[9]))
    }

    func test_monthRecords_should_includeOnlyDaysOfDisplayedMonth() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let keys = vm.monthRecords.map(\.dayKey)

        // Assert
        XCTAssertEqual(keys, ["2026-10-05", "2026-10-06", "2026-10-20", "2026-10-21"])
    }

    func test_summaryCounts_should_deriveFromMonthRecords() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let active = vm.activeDayCount
        let perfect = vm.perfectDayCount
        let completed = vm.completedTaskCount

        // Assert
        XCTAssertEqual(active, 3)
        XCTAssertEqual(perfect, 2)
        XCTAssertEqual(completed, 6)
    }

    func test_summaryCounts_should_beZeroForMonthWithoutHistory() {
        // Arrange
        let vm = makeSeededViewModel()
        vm.displayedMonth = TestClock.date(year: 2025, month: 1, day: 1, hour: 0)

        // Act
        let counts = [vm.activeDayCount, vm.perfectDayCount, vm.completedTaskCount]

        // Assert
        XCTAssertEqual(counts, [0, 0, 0])
        XCTAssertTrue(vm.monthRecords.isEmpty)
    }

    func test_weekdaySymbols_should_startAtCalendarFirstWeekday() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let symbols = vm.weekdaySymbols

        // Assert
        XCTAssertEqual(symbols.count, 7)
        XCTAssertEqual(symbols.first, calendar.shortWeekdaySymbols[calendar.firstWeekday - 1])
        XCTAssertEqual(Set(symbols), Set(calendar.shortWeekdaySymbols))
    }

    func test_monthDays_should_listEveryDayOfMonthWithLeadingPadding() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let days = vm.monthDays

        // Assert
        let realDays = days.compactMap { $0 }
        XCTAssertEqual(realDays.count, 31)
        XCTAssertEqual(realDays.map(\.dayNumber), Array(1...31))
        XCTAssertEqual(realDays.first?.id, "2026-10-01")
        let leading = days.prefix { $0 == nil }.count
        XCTAssertLessThan(leading, 7)
        for (index, day) in days.enumerated() {
            guard let day else { continue }
            let weekday = calendar.component(.weekday, from: day.date)
            XCTAssertEqual(index % 7, (weekday - calendar.firstWeekday + 7) % 7, day.dayKey)
        }
    }

    func test_monthDays_should_attachFullRecordsToTrackedDays() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        let days = vm.monthDays.compactMap { $0 }

        // Assert
        let fifth = days.first { $0.dayKey == "2026-10-05" }
        XCTAssertEqual(fifth?.record?.completedCount, 3)
        XCTAssertEqual(fifth?.record?.tasks.count, 3)
        XCTAssertTrue(fifth?.record?.isPerfectDay ?? false)
        XCTAssertNil(days.first { $0.dayKey == "2026-10-04" }?.record)
        XCTAssertEqual(days.filter { $0.record != nil }.count, 4)
    }

    func test_moveMonth_should_advanceToStartOfNextMonth() {
        // Arrange
        let vm = makeSeededViewModel()
        vm.taskManager.toggleTaskCompletion(task: vm.taskManager.tasks[0])

        // Act
        vm.moveMonth(by: 1)

        // Assert
        XCTAssertEqual(TrackerDayKey.key(for: vm.displayedMonth), "2026-11-01")
        XCTAssertEqual(vm.monthRecords.map(\.dayKey), ["2026-11-03"])
    }

    func test_moveMonth_should_goBackAcrossYearBoundary() {
        // Arrange
        let vm = makeSeededViewModel()

        // Act
        vm.moveMonth(by: -10)

        // Assert
        XCTAssertEqual(TrackerDayKey.key(for: vm.displayedMonth), "2025-12-01")
    }

    func test_startOfMonth_should_dropDayAndTime() {
        // Arrange
        let vm = makeSeededViewModel()
        let date = TestClock.date(year: 2024, month: 2, day: 29, hour: 18)

        // Act
        let start = vm.startOfMonth(date)

        // Assert
        XCTAssertEqual(start, calendar.startOfDay(for: TestClock.date(year: 2024, month: 2, day: 1)))
    }
}
