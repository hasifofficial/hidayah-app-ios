//
//  RakaatFeedback.swift
//  hidayah-app
//

import Foundation

/// The haptic cue for a set of rakaat events, shared by iPhone and Watch
/// so both feel the same.
enum RakaatCue: Equatable {
    /// A rakaat is done.
    case rakaat
    /// Sit for tashahhud: a firmer double tap.
    case tashahhud
    /// The prayer is complete.
    case complete

    /// The one cue to play for `events`. When a change does several things
    /// at once, the most important wins.
    static func cue(for events: [RakaatEvent]) -> RakaatCue? {
        if events.contains(.prayerCompleted) {
            return .complete
        }
        if events.contains(where: { if case .tashahhud = $0 { return true } else { return false } }) {
            return .tashahhud
        }
        if events.contains(where: { if case .rakaatCompleted = $0 { return true } else { return false } }) {
            return .rakaat
        }
        return nil
    }
}

@MainActor
enum RakaatFeedback {
    /// The gap between the two taps of the tashahhud cue.
    static let doubleTapGap: TimeInterval = 0.3

    static func play(for events: [RakaatEvent]) {
        guard let cue = RakaatCue.cue(for: events) else { return }
        play(cue)
    }

    static func play(_ cue: RakaatCue) {
        switch cue {
        case .rakaat:
            AppHaptics.tap()
        case .tashahhud:
            AppHaptics.impact(intensity: 1)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(doubleTapGap * 1_000_000_000))
                AppHaptics.impact(intensity: 1)
            }
        case .complete:
            AppHaptics.success()
        }
    }
}
