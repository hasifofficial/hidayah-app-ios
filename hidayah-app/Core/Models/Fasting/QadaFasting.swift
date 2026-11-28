//
//  QadaFasting.swift
//  hidayah-app
//
//  The Qada fasting ledger: Ramadan days owed per Hijri year, and the
//  makeup fasts kept against them.
//

import Foundation

/// One makeup fast, counted against the Ramadan of `hijriYear`.
struct QadaFast: Identifiable, Equatable {
    let id: UUID
    /// The start of the day the fast was kept.
    let date: Date
    let hijriYear: Int

    init(id: UUID = UUID(), date: Date, hijriYear: Int) {
        self.id = id
        self.date = date
        self.hijriYear = hijriYear
    }
}

/// The days owed for one Ramadan and how many have been made up.
struct QadaYear: Identifiable, Equatable {
    /// A Ramadan has at most 30 days.
    static let maxOwedDays = 30

    let hijriYear: Int
    let owedDays: Int
    let madeUpDays: Int

    var id: Int { hijriYear }

    var remainingDays: Int {
        max(owedDays - madeUpDays, 0)
    }

    var isComplete: Bool {
        remainingDays == 0
    }

    var progress: Double {
        guard owedDays > 0 else { return 0 }
        return min(Double(madeUpDays) / Double(owedDays), 1)
    }
}

/// Everything the Qada screen shows, derived from the stored rows.
struct QadaLedger: Equatable {
    /// Oldest Ramadan first.
    let years: [QadaYear]
    /// Newest fast first.
    let fasts: [QadaFast]

    static let empty = QadaLedger(owedDays: [:], fasts: [])

    init(owedDays: [Int: Int], fasts: [QadaFast]) {
        let madeUp = Dictionary(grouping: fasts, by: \.hijriYear)
            .mapValues(\.count)

        years = owedDays.keys.sorted().map { year in
            QadaYear(
                hijriYear: year,
                owedDays: owedDays[year] ?? 0,
                madeUpDays: madeUp[year] ?? 0
            )
        }
        self.fasts = fasts.sorted { $0.date > $1.date }
    }

    var totalOwed: Int {
        years.reduce(0) { $0 + $1.owedDays }
    }

    var totalMadeUp: Int {
        years.reduce(0) { $0 + min($1.madeUpDays, $1.owedDays) }
    }

    var totalRemaining: Int {
        years.reduce(0) { $0 + $1.remainingDays }
    }

    var progress: Double {
        guard totalOwed > 0 else { return 0 }
        return Double(totalMadeUp) / Double(totalOwed)
    }

    /// The oldest Ramadan with days still owed: a new fast counts against
    /// it, so the earliest debts are cleared first.
    var yearForNextFast: Int? {
        years.first { !$0.isComplete }?.hijriYear
    }

    func year(_ hijriYear: Int) -> QadaYear? {
        years.first { $0.hijriYear == hijriYear }
    }
}
