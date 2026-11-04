//
//  MathuratViewModel.swift
//  simple-quran
//

import Foundation
import Observation

@MainActor
@Observable
final class MathuratViewModel {
    private(set) var time: MathuratTime
    private(set) var entries: [MathuratEntry] = []
    private(set) var isLoaded = false
    private(set) var loadError: MathuratLoadError?

    @ObservationIgnored
    private let loader: MathuratLoading

    @ObservationIgnored
    private let now: () -> Date

    @ObservationIgnored
    private let calendar: Calendar

    @ObservationIgnored
    private var loaded: [MathuratTime: [MathuratEntry]] = [:]

    /// Counts per session and entry id. Kept in memory only, so switching
    /// from morning to evening keeps the morning's progress for the day.
    private var counts: [MathuratTime: [Int: Int]] = [:]

    /// How far down each session is scrolled, from 0 to 1.
    private var readFractions: [MathuratTime: Double] = [:]

    init(
        loader: MathuratLoading = BundleMathuratLoader(),
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.loader = loader
        self.now = now
        self.calendar = calendar
        time = MathuratTime.current(at: now(), calendar: calendar)
    }

    /// Seconds until the time of day next changes, so the view can switch
    /// on its own while open.
    var secondsUntilTimeChange: TimeInterval {
        let next = MathuratTime.nextChange(after: now(), calendar: calendar)
        return max(next.timeIntervalSince(now()), 1)
    }

    func loadIfNeeded() {
        guard !isLoaded, loadError == nil else { return }
        load()
    }

    func retry() {
        loadError = nil
        load()
    }

    /// Re-reads the clock and switches between morning and evening when the
    /// time of day has changed.
    func refreshTime() {
        let current = MathuratTime.current(at: now(), calendar: calendar)
        guard current != time else { return }
        time = current
        load()
    }

    func count(for entry: MathuratEntry) -> Int {
        counts[time]?[entry.id] ?? 0
    }

    func isComplete(_ entry: MathuratEntry) -> Bool {
        count(for: entry) >= entry.repeatCount
    }

    func increment(_ entry: MathuratEntry) {
        let current = count(for: entry)
        guard current < entry.repeatCount else { return }

        counts[time, default: [:]][entry.id] = current + 1

        if current + 1 == entry.repeatCount {
            AppHaptics.success()
        } else {
            AppHaptics.tap()
        }
    }

    /// Records how far down the current session is scrolled. It follows the
    /// scroll position both ways, so scrolling back up lowers it.
    func updateReadFraction(_ fraction: Double) {
        guard isLoaded else { return }
        readFractions[time] = min(max(fraction, 0), 1)
    }

    /// How far down the current session is scrolled, from 0 to 1.
    var progress: Double {
        readFractions[time] ?? 0
    }

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    private func load() {
        if let cached = loaded[time] {
            entries = cached
            isLoaded = true
            loadError = nil
            return
        }

        do {
            let result = try loader.entries(for: time)
            loaded[time] = result
            entries = result
            isLoaded = true
            loadError = nil
        } catch let error as MathuratLoadError {
            entries = []
            isLoaded = false
            loadError = error
        } catch {
            entries = []
            isLoaded = false
            loadError = .corrupt
        }
    }
}
