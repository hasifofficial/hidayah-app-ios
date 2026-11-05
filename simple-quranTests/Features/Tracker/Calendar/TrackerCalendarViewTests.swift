//
//  TrackerCalendarViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

private extension Calendar {
    func startOfMonth(_ date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date))!
    }
}

@MainActor
final class TrackerCalendarViewTests: XCTestCase {
    private var selectedDays: [String] = []

    private let calendar = TrackerDayKey.calendar

    private func makeHost(_ taskManager: TaskManager) -> ViewHost<some View> {
        let host = ViewHost(
            NavigationStack {
                TrackerCalendarView(
                    taskManager: taskManager,
                    onSelectDay: { self.selectedDays.append($0) }
                )
            }
        )
        host.pump(0.6)
        return host
    }

    private func daysAgo(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: Date())!
    }

    private func monthTitle(for date: Date, _ taskManager: TaskManager) -> String {
        let viewModel = TrackerCalendarViewModel(taskManager: taskManager)
        viewModel.displayedMonth = viewModel.startOfMonth(date)
        return viewModel.monthTitle
    }

    private func dayLabel(
        _ date: Date,
        percent: Int,
        _ taskManager: TaskManager
    ) -> String {

        "\(calendar.component(.day, from: date)) \(monthTitle(for: date, taskManager)), \(percent) percent complete"

    }

    /// Moves the calendar from the current month to the month of `date`.
    private func show<V: View>(_ date: Date, in host: ViewHost<V>) {
        let months = calendar.dateComponents(
            [.month],
            from: calendar.startOfMonth(Date()),
            to: calendar.startOfMonth(date)
        ).month ?? 0
        for _ in 0..<abs(months) {
            host.tap(months < 0 ? "Back" : "Forward")
        }
        host.pump(0.4)
    }

    func test_body_should_labelEveryDayWithItsProgress() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture(start: daysAgo(2))
        builder.record([1, 3])
        let partialDay = daysAgo(2)
        let perfectDay = daysAgo(1)

        // Act
        let host = makeHost(taskManager)
        let currentTitle = monthTitle(for: Date(), taskManager)
        let initialLabels = host.labels()
        show(partialDay, in: host)
        let partialVisible = host.contains(dayLabel(partialDay, percent: 33, taskManager))
        host.tap("Today")
        show(perfectDay, in: host)
        let perfectVisible = host.contains(dayLabel(perfectDay, percent: 100, taskManager))

        // Assert
        XCTAssertTrue(initialLabels.contains(currentTitle))
        XCTAssertTrue(initialLabels.contains("Complete"))
        XCTAssertTrue(initialLabels.contains("Partial"))
        XCTAssertTrue(initialLabels.contains("Missed"))
        XCTAssertTrue(initialLabels.contains("Active days"))
        XCTAssertTrue(partialVisible, "\(host.labels())")
        XCTAssertTrue(perfectVisible, "\(host.labels())")
    }

    func test_tappingAPastDay_should_selectIt() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture(start: daysAgo(1))
        builder.record([3])
        let day = daysAgo(1)
        let host = makeHost(taskManager)
        show(day, in: host)

        // Act
        host.tap(dayLabel(day, percent: 100, taskManager))

        // Assert
        XCTAssertEqual(selectedDays, [TrackerDayKey.key(for: day)])
    }

    func test_tappingAFutureDay_should_doNothing() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: calendar.startOfMonth(Date()))!
        host.tap("Forward")

        // Act
        host.tap(dayLabel(nextMonth, percent: 0, taskManager))

        // Assert
        XCTAssertTrue(selectedDays.isEmpty)
        XCTAssertTrue(host.contains(monthTitle(for: nextMonth, taskManager)))
    }

    func test_backForwardAndToday_should_changeTheShownMonth() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        let previous = calendar.date(byAdding: .month, value: -1, to: Date())!

        // Act
        host.tap("Back")
        host.pump(0.3)
        let afterBack = host.labels()
        host.tap("Today")
        host.pump(0.3)
        let afterToday = host.labels()

        // Assert
        XCTAssertTrue(afterBack.contains(monthTitle(for: previous, taskManager)))
        XCTAssertTrue(afterToday.contains(monthTitle(for: Date(), taskManager)))
    }

    func test_monthPicker_should_jumpToTheChosenMonth() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        let year = calendar.component(.year, from: Date())
        let january = TrackerDayKey.date(from: String(format: "%04d-01-01", year - 1))!
        host.tap(monthTitle(for: Date(), taskManager))
        host.pump(0.8)

        // Act
        host.select(row: 0, inPickerAt: 0)
        host.select(row: 19, inPickerAt: 1)
        host.tap("Go")
        host.pump(0.8)

        // Assert
        XCTAssertNil(host.controller.presentedViewController)
        XCTAssertTrue(host.labels().contains(monthTitle(for: january, taskManager)), "\(host.labels())")
    }

    func test_monthPickerCancel_should_keepTheShownMonth() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture(start: Date())
        let host = makeHost(taskManager)
        let current = monthTitle(for: Date(), taskManager)
        host.tap(current)
        host.pump(0.8)

        // Act
        host.select(row: 0, inPickerAt: 0)
        host.tap("Cancel")
        host.pump(0.8)

        // Assert
        XCTAssertNil(host.controller.presentedViewController)
        XCTAssertTrue(host.labels().contains(current))
    }
}
