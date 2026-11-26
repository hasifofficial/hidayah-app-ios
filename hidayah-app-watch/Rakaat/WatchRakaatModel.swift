//
//  WatchRakaatModel.swift
//  hidayah-app-watch
//

import Foundation
import Observation
import WatchKit

/// Rakaat on the wrist. While the iPhone counts a prayer, this mirrors it
/// and plays the cues the phone on the mat can't make you feel. Without the
/// iPhone it counts on its own from taps and the Crown.
@MainActor
@Observable
final class WatchRakaatModel: NSObject {
    /// The iPhone's session while it is running.
    private(set) var live: RakaatLiveState?
    /// The Watch's own count, while one runs.
    private(set) var counter: RakaatCounter?
    /// The prayer just finished, shown until you dismiss it.
    private(set) var completedPrayer: RakaatPrayer?
    /// Set by the latest tashahhud cue, until the next rakaat.
    private(set) var isTashahhudPrompt = false
    var prayer: RakaatPrayer = .dhuhr

    @ObservationIgnored private let link: WatchTrackerModel
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var lastSessionID: UUID?
    @ObservationIgnored private var lastSequence = 0
    @ObservationIgnored private var runtimeSession: WKExtendedRuntimeSession?

    init(link: WatchTrackerModel, now: @escaping () -> Date = Date.init) {
        self.link = link
        self.now = now
        super.init()
        link.onRakaatState = { [weak self] state in
            self?.receive(state)
        }
    }

    var isMirroring: Bool { live != nil }

    var completedRakaat: Int {
        live?.completedRakaat ?? counter?.completedRakaat ?? 0
    }

    var rakaatCount: Int {
        live?.prayer.rakaatCount ?? counter?.rakaatCount ?? prayer.rakaatCount
    }

    var sujoodInCurrentRakaat: Int {
        live?.sujoodInCurrentRakaat ?? 0
    }

    var progress: Double {
        guard rakaatCount > 0 else { return 0 }
        return min(Double(completedRakaat) / Double(rakaatCount), 1)
    }

    var displayedPrayer: RakaatPrayer {
        live?.prayer ?? counter?.prayer ?? prayer
    }

    // MARK: - Standalone counting

    func start() {
        counter = RakaatCounter(prayer: prayer)
        isTashahhudPrompt = false
        completedPrayer = nil
        startRuntime()
    }

    func increment() {
        if let live {
            link.send(RakaatCommand(sessionID: live.sessionID, action: .increment))
            return
        }
        guard var counter else { return }
        let events = counter.manualIncrement()
        self.counter = counter
        handle(events, prayer: counter.prayer)
        if events.contains(.prayerCompleted) {
            self.counter = nil
            stopRuntimeIfIdle()
        }
    }

    func decrement() {
        if let live {
            link.send(RakaatCommand(sessionID: live.sessionID, action: .decrement))
            return
        }
        guard var counter else { return }
        counter.manualDecrement()
        self.counter = counter
        isTashahhudPrompt = false
        AppHaptics.tap()
    }

    func stop() {
        counter = nil
        stopRuntimeIfIdle()
    }

    func dismissCompletion() {
        completedPrayer = nil
    }

    // MARK: - iPhone session

    func receive(_ state: RakaatLiveState) {
        if state.isStale(now: now()) {
            if live?.sessionID == state.sessionID {
                live = nil
                stopRuntimeIfIdle()
            }
            return
        }

        if state.sessionID != lastSessionID {
            lastSessionID = state.sessionID
            lastSequence = 0
        }
        // Context and live messages can bring the same update twice.
        guard state.sequence > lastSequence else { return }
        lastSequence = state.sequence

        handle(state.events, prayer: state.prayer)

        if state.isActive {
            if live == nil {
                // The phone's session takes over from a local count.
                counter = nil
                completedPrayer = nil
            }
            live = state
            startRuntime()
        } else {
            live = nil
            stopRuntimeIfIdle()
        }
    }

    // MARK: - Private

    private func handle(_ events: [RakaatEvent], prayer: RakaatPrayer) {
        guard !events.isEmpty else { return }
        RakaatFeedback.play(for: events)
        if events.contains(where: { if case .rakaatCompleted = $0 { return true } else { return false } }) {
            isTashahhudPrompt = events.contains(.tashahhud(isFinal: false))
        }
        if events.contains(.prayerCompleted) {
            isTashahhudPrompt = false
            completedPrayer = prayer
        }
    }

    /// Keeps the app running with the wrist down, so the cues keep coming
    /// for the whole prayer.
    private func startRuntime() {
        guard runtimeSession == nil else { return }
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
        runtimeSession = session
    }

    private func stopRuntimeIfIdle() {
        guard live == nil, counter == nil else { return }
        runtimeSession?.invalidate()
        runtimeSession = nil
    }
}

extension WatchRakaatModel: WKExtendedRuntimeSessionDelegate {
    nonisolated func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    nonisolated func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    nonisolated func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        let id = ObjectIdentifier(extendedRuntimeSession)
        Task { @MainActor in
            if let current = self.runtimeSession, ObjectIdentifier(current) == id {
                self.runtimeSession = nil
            }
        }
    }
}
