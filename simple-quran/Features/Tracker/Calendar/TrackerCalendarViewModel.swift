//
//  TrackerCalendarViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

struct TrackerCalendarDay: Identifiable {
    let dayKey: String
    let date: Date
    let record: TrackerDayRecord?

    var id: String { dayKey }

    var dayNumber: Int {
        TrackerDayKey.calendar.component(.day, from: date)
    }
}

@Observable
final class TrackerCalendarViewModel {
    let taskManager: TaskManager
    var displayedMonth: Date

    init(taskManager: TaskManager) {
        self.taskManager = taskManager

        let calendar = TrackerDayKey.calendar
        let components = calendar.dateComponents(
            [.year, .month],
            from: Date()
        )
        displayedMonth = calendar.date(from: components) ?? Date()
    }

    var calendar: Calendar {
        TrackerDayKey.calendar
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    var startDayKey: String? {
        taskManager.startDayKey
    }

    var monthRecords: [TrackerDayRecord] {
        taskManager.records(in: displayedMonth)
    }

    var activeDayCount: Int {
        monthRecords.filter { $0.completedCount > 0 }.count
    }

    var perfectDayCount: Int {
        monthRecords.filter(\.isPerfectDay).count
    }

    var completedTaskCount: Int {
        monthRecords.reduce(0) { $0 + $1.completedCount }
    }

    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let shift = max(0, calendar.firstWeekday - 1)
        return Array(symbols[shift...] + symbols[..<shift])
    }

    var monthDays: [TrackerCalendarDay?] {
        guard let dayRange = calendar.range(
            of: .day,
            in: .month,
            for: displayedMonth
        ) else {
            return []
        }

        let firstWeekday = calendar.component(
            .weekday,
            from: displayedMonth
        )
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [TrackerCalendarDay?] = Array(
            repeating: nil,
            count: leading
        )

        for day in dayRange {
            guard let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: displayedMonth
            ) else {
                continue
            }

            let key = TrackerDayKey.key(for: date, calendar: calendar)
            days.append(
                TrackerCalendarDay(
                    dayKey: key,
                    date: date,
                    record: taskManager.record(for: key)
                )
            )
        }

        return days
    }

    func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) else {
            return
        }
        displayedMonth = startOfMonth(newMonth)
    }

    func startOfMonth(_ date: Date) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: date)
        ) ?? date
    }
}
