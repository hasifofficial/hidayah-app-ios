//
//  RamadanCalendar.swift
//  hidayah-app
//

import Foundation

/// Hijri date questions the Qada tracker asks, answered with the Umm
/// al-Qura calendar.
struct RamadanCalendar {
    static let ramadanMonth = 9

    private let hijri: Calendar
    private let gregorian: Calendar

    init(timeZone: TimeZone = .current) {
        var hijri = Calendar(identifier: .islamicUmmAlQura)
        hijri.timeZone = timeZone
        self.hijri = hijri

        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone
        self.gregorian = gregorian
    }

    func hijriYear(of date: Date) -> Int {
        hijri.component(.year, from: date)
    }

    /// The most recent Ramadan that has started by `date`: this Hijri year's
    /// once Ramadan begins, otherwise last year's.
    func latestRamadanYear(asOf date: Date) -> Int {
        let components = hijri.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        return (components.month ?? 0) >= Self.ramadanMonth ? year : year - 1
    }

    /// The first day of the next Ramadan that begins after `date`.
    func nextRamadanStart(after date: Date) -> Date? {
        let year = latestRamadanYear(asOf: date) + 1
        return hijri.date(
            from: DateComponents(year: year, month: Self.ramadanMonth, day: 1)
        ).map { startOfDay($0) }
    }

    /// Whole days from `date` to the start of the next Ramadan.
    func daysUntilNextRamadan(from date: Date) -> Int? {
        guard let start = nextRamadanStart(after: date) else { return nil }
        return gregorian.dateComponents(
            [.day],
            from: startOfDay(date),
            to: start
        ).day
    }

    func startOfDay(_ date: Date) -> Date {
        gregorian.startOfDay(for: date)
    }

    func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        gregorian.isDate(lhs, inSameDayAs: rhs)
    }
}
