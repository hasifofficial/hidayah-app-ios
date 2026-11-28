//
//  QadaFastingViewModel.swift
//  hidayah-app
//

import Foundation
import Observation

/// State and wording for the Qada fasting screen. The ledger itself lives
/// in `QadaFastingManager`.
@MainActor
@Observable
final class QadaFastingViewModel {
    enum Sheet: Identifiable, Equatable {
        case addYear
        case editYear(Int)
        case logFast

        var id: String {
            switch self {
            case .addYear:
                return "addYear"
            case .editYear(let year):
                return "editYear-\(year)"
            case .logFast:
                return "logFast"
            }
        }
    }

    /// Logged fasts in one calendar month, for the timeline.
    struct FastSection: Identifiable, Equatable {
        let id: String
        let title: String
        let fasts: [QadaFast]
    }

    var sheet: Sheet?
    /// A fast waiting for the user to confirm its removal.
    var fastPendingRemoval: QadaFast?
    /// Bumped each time a fast is logged, to play the celebration.
    private(set) var celebration = 0
    /// A short dua shown after logging a fast; the view clears it.
    var toast: String?

    let manager: QadaFastingManager

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM yyyy")
        return formatter
    }()
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    init(manager: QadaFastingManager = .shared) {
        self.manager = manager
    }

    func onAppear() {
        manager.reload()
    }

    // MARK: - Summary

    var ledger: QadaLedger {
        manager.ledger
    }

    var isEmpty: Bool {
        ledger.years.isEmpty
    }

    var isAllMadeUp: Bool {
        !isEmpty && ledger.totalRemaining == 0
    }

    var remainingCount: String {
        "\(ledger.totalRemaining)"
    }

    var remainingLabel: String {
        NSLocalizedString(
            ledger.totalRemaining == 1 ? "qada_day_left" : "qada_days_left",
            comment: ""
        )
    }

    /// How full the hero's moon is: the share of owed days made up.
    var moonPhase: Double {
        ledger.progress
    }

    var heroSummary: String {
        isAllMadeUp ? NSLocalizedString("qada_all_made_up", comment: "") : summaryText
    }

    /// The Ramadan the next fast will count against.
    var nextYear: Int? {
        ledger.yearForNextFast
    }

    var summaryText: String {
        String(
            format: NSLocalizedString("qada_summary_made_up", comment: ""),
            ledger.totalMadeUp,
            ledger.totalOwed
        )
    }

    /// When the next Ramadan begins, the usual deadline for making up the
    /// last one: "Ramadan 1448 begins" and "in 72 days".
    struct Deadline: Equatable {
        let label: String
        let countdown: String
    }

    var deadline: Deadline? {
        guard let days = manager.daysUntilNextRamadan else { return nil }

        let countdown: String
        switch days {
        case ...0:
            countdown = NSLocalizedString("qada_deadline_today", comment: "")
        case 1:
            countdown = NSLocalizedString("qada_deadline_tomorrow", comment: "")
        default:
            countdown = String(format: NSLocalizedString("qada_deadline_in_days", comment: ""), days)
        }

        return Deadline(
            label: String(
                format: NSLocalizedString("qada_deadline_label", comment: ""),
                manager.nextRamadanYear
            ),
            countdown: countdown
        )
    }

    // MARK: - Logging

    /// Logs a fast on `date`. Returns an error to show, or nil once the
    /// fast is logged.
    func logFast(on date: Date) -> String? {
        switch manager.logFast(on: date) {
        case .logged:
            celebrate()
            return nil
        case .alreadyLogged:
            return NSLocalizedString("qada_error_already_logged", comment: "")
        case .inFuture:
            return NSLocalizedString("qada_error_future", comment: "")
        case .nothingOwed:
            return NSLocalizedString("qada_error_nothing_owed", comment: "")
        }
    }

    var today: Date {
        manager.today
    }

    private func celebrate() {
        AppHaptics.success()
        celebration += 1
        toast = NSLocalizedString(
            isAllMadeUp ? "qada_toast_complete" : "qada_toast_logged",
            comment: ""
        )
    }

    func confirmFastRemoval() {
        guard let fast = fastPendingRemoval else { return }
        manager.deleteFast(id: fast.id)
        fastPendingRemoval = nil
    }

    // MARK: - Years

    var canAddYear: Bool {
        !manager.availableYears().isEmpty
    }

    /// A fast can be logged while any day is still owed.
    var canLogFast: Bool {
        ledger.yearForNextFast != nil
    }

    /// Where the log sheet's calendar starts: today, or yesterday once
    /// today is logged.
    var suggestedLogDate: Date {
        guard manager.hasLoggedToday else { return manager.today }
        return Calendar.current.date(byAdding: .day, value: -1, to: manager.today) ?? manager.today
    }

    /// The floating + menu shows once there's a ledger and it has an item.
    var showsAddMenu: Bool {
        !isEmpty && (canLogFast || canAddYear)
    }

    var addableYears: [Int] {
        manager.availableYears()
    }

    func saveYear(_ hijriYear: Int, owedDays: Int) {
        manager.setOwedDays(owedDays, for: hijriYear)
    }

    func removeYear(_ hijriYear: Int) {
        manager.removeYear(hijriYear)
    }

    // MARK: - Formatting

    func yearTitle(_ hijriYear: Int) -> String {
        String(format: NSLocalizedString("qada_year_title", comment: ""), hijriYear)
    }

    func yearDetail(_ year: QadaYear) -> String {
        if year.isComplete {
            return NSLocalizedString("qada_year_complete", comment: "")
        }
        return String(
            format: NSLocalizedString("qada_year_progress", comment: ""),
            year.madeUpDays,
            year.owedDays
        )
    }

    func dateText(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// Fasts grouped by calendar month, newest first.
    var fastSections: [FastSection] {
        let calendar = Calendar.current
        var sections: [FastSection] = []

        for fast in ledger.fasts {
            let parts = calendar.dateComponents([.year, .month], from: fast.date)
            let id = "\(parts.year ?? 0)-\(parts.month ?? 0)"

            if let last = sections.last, last.id == id {
                sections[sections.count - 1] = FastSection(
                    id: id,
                    title: last.title,
                    fasts: last.fasts + [fast]
                )
            } else {
                sections.append(
                    FastSection(id: id, title: monthFormatter.string(from: fast.date), fasts: [fast])
                )
            }
        }
        return sections
    }

    /// The day number and short weekday for a fast's date badge.
    func dayBadge(_ fast: QadaFast) -> (day: String, weekday: String) {
        (
            "\(Calendar.current.component(.day, from: fast.date))",
            weekdayFormatter.string(from: fast.date)
        )
    }

    func fastDetail(_ fast: QadaFast) -> String {
        String(format: NSLocalizedString("qada_fast_for_year", comment: ""), fast.hijriYear)
    }

    static func daysText(_ days: Int) -> String {
        String(
            format: NSLocalizedString(days == 1 ? "qada_day_count_one" : "qada_day_count", comment: ""),
            days
        )
    }
}
