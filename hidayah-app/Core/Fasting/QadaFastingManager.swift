//
//  QadaFastingManager.swift
//  hidayah-app
//

import Foundation

/// The Qada fasting domain facade: Ramadan days owed per Hijri year, and
/// the makeup fasts kept against them.
@MainActor
@Observable
final class QadaFastingManager {
    static let shared = QadaFastingManager()

    enum LogResult: Equatable {
        case logged(hijriYear: Int)
        /// Every Ramadan is fully made up.
        case nothingOwed
        /// A fast is already logged on that day.
        case alreadyLogged
        case inFuture
    }

    private(set) var ledger: QadaLedger = .empty

    let calendar: RamadanCalendar
    private let store: HidayahStore
    private let now: () -> Date

    init(
        store: HidayahStore = .shared,
        calendar: RamadanCalendar = RamadanCalendar(),
        now: @escaping () -> Date = Date.init
    ) {
        self.store = store
        self.calendar = calendar
        self.now = now
        reload()
    }

    func reload() {
        store.reconnectIfNeeded()
        ledger = store.loadQadaLedger()
    }

    // MARK: - Dates

    var today: Date {
        calendar.startOfDay(now())
    }

    /// The newest Ramadan days can be owed for.
    var latestRamadanYear: Int {
        calendar.latestRamadanYear(asOf: now())
    }

    var nextRamadanYear: Int {
        latestRamadanYear + 1
    }

    var daysUntilNextRamadan: Int? {
        calendar.daysUntilNextRamadan(from: now())
    }

    /// Past Ramadans not on the ledger yet, newest first.
    func availableYears(lookingBack count: Int = 30) -> [Int] {
        let tracked = Set(ledger.years.map(\.hijriYear))
        let latest = latestRamadanYear
        return (0..<count)
            .map { latest - $0 }
            .filter { !tracked.contains($0) }
    }

    // MARK: - Years

    /// Sets the days owed for a Ramadan, adding it if new. The count is kept
    /// between the days already made up and 30, so logged fasts are never
    /// orphaned. Setting zero on a year with no fasts removes it.
    func setOwedDays(_ days: Int, for hijriYear: Int) {
        let madeUp = ledger.year(hijriYear)?.madeUpDays ?? 0
        let clamped = min(max(days, madeUp), QadaYear.maxOwedDays)

        if clamped == 0 {
            if ledger.year(hijriYear) != nil {
                store.deleteQadaYear(hijriYear)
            }
        } else {
            store.saveQadaYear(hijriYear: hijriYear, owedDays: clamped)
        }
        reload()
    }

    /// Removes a Ramadan and the fasts counted against it. Only call this
    /// from an explicit, confirmed user action.
    func removeYear(_ hijriYear: Int) {
        store.deleteQadaYear(hijriYear)
        reload()
    }

    // MARK: - Fasts

    func hasFast(on date: Date) -> Bool {
        ledger.fasts.contains { calendar.isSameDay($0.date, date) }
    }

    var hasLoggedToday: Bool {
        hasFast(on: now())
    }

    /// Logs a makeup fast on `date`, counting it against the oldest Ramadan
    /// still owed.
    @discardableResult
    func logFast(on date: Date) -> LogResult {
        let day = calendar.startOfDay(date)

        guard day <= today else { return .inFuture }
        guard !hasFast(on: day) else { return .alreadyLogged }
        guard let year = ledger.yearForNextFast else { return .nothingOwed }

        store.insertQadaFast(QadaFast(date: day, hijriYear: year))
        reload()
        return .logged(hijriYear: year)
    }

    func deleteFast(id: UUID) {
        store.deleteQadaFast(id: id)
        reload()
    }
}
