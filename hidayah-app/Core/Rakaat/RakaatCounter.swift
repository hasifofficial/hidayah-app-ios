//
//  RakaatCounter.swift
//  hidayah-app
//

import Foundation

/// Something the counter noticed, in the order it happened.
enum RakaatEvent: Codable, Equatable {
    /// A sujood was counted; the value is how many in this rakaat so far.
    case sujoodCounted(Int)
    /// A rakaat finished; the value is how many are done.
    case rakaatCompleted(Int)
    /// Time to sit for tashahhud. `isFinal` is true at the last rakaat.
    case tashahhud(isFinal: Bool)
    case prayerCompleted
}

/// Counts rakaat from the proximity sensor: the forehead near the phone is
/// a sujood, and the second sujood of a rakaat ends it.
///
/// It has no timers or platform code, so the Watch can use it and tests can
/// drive it with exact times. The owner feeds it sensor changes and calls
/// `advance(to:)` shortly after a "far" so a finished sujood is counted
/// without waiting for the next sensor change.
struct RakaatCounter: Equatable {
    /// How long the forehead must stay near for the change to be a sujood
    /// and not a hand passing over the phone.
    static let minimumSujoodDuration: TimeInterval = 0.8
    /// A "far" shorter than this is the sensor flickering, so it joins the
    /// sujood either side of it.
    static let flickerGap: TimeInterval = 0.4

    let prayer: RakaatPrayer
    private(set) var completedRakaat = 0
    private(set) var sujoodInCurrentRakaat = 0

    /// When the current near began, while one is in progress.
    private var nearStart: Date?
    /// When the sensor last went far after a near, until the flicker gap
    /// has passed and the sujood is settled.
    private var pendingEnd: Date?

    init(prayer: RakaatPrayer) {
        self.prayer = prayer
    }

    var rakaatCount: Int { prayer.rakaatCount }

    var isComplete: Bool { completedRakaat >= rakaatCount }

    /// How far through the prayer, from 0 to 1.
    var progress: Double {
        guard rakaatCount > 0 else { return 0 }
        return min(Double(completedRakaat) / Double(rakaatCount), 1)
    }

    /// Whether the forehead is near the phone right now.
    var isInSujood: Bool { nearStart != nil && pendingEnd == nil }

    /// Feeds one proximity change. Returns what it completed, if anything.
    mutating func proximityChanged(isNear: Bool, at time: Date) -> [RakaatEvent] {
        guard !isComplete else { return [] }

        if isNear {
            var events: [RakaatEvent] = []
            if let end = pendingEnd {
                if time.timeIntervalSince(end) < Self.flickerGap {
                    // Back near within the gap: the same sujood goes on.
                    pendingEnd = nil
                    return []
                }
                // The owner didn't advance in time; settle the last one now.
                events = settle()
            }
            if !isComplete, nearStart == nil {
                nearStart = time
            }
            return events
        }

        if nearStart != nil, pendingEnd == nil {
            pendingEnd = time
        }
        return []
    }

    /// Settles a sujood whose flicker gap has passed by `time`.
    mutating func advance(to time: Date) -> [RakaatEvent] {
        guard let end = pendingEnd,
              time.timeIntervalSince(end) >= Self.flickerGap else {
            return []
        }
        return settle()
    }

    /// Counts a whole rakaat by hand, for taps, the Crown or a missed
    /// sujood.
    mutating func manualIncrement() -> [RakaatEvent] {
        guard !isComplete else { return [] }
        clearSujood()
        sujoodInCurrentRakaat = 0
        return completeRakaat()
    }

    /// Takes back one rakaat by hand. A part-done rakaat is cleared first.
    mutating func manualDecrement() {
        clearSujood()
        if sujoodInCurrentRakaat > 0 {
            sujoodInCurrentRakaat = 0
        } else if completedRakaat > 0 {
            completedRakaat -= 1
        }
    }

    mutating func reset() {
        clearSujood()
        completedRakaat = 0
        sujoodInCurrentRakaat = 0
    }

    // MARK: - Private

    private mutating func settle() -> [RakaatEvent] {
        guard let start = nearStart, let end = pendingEnd else { return [] }
        clearSujood()
        guard end.timeIntervalSince(start) >= Self.minimumSujoodDuration else {
            return []
        }

        sujoodInCurrentRakaat += 1
        var events: [RakaatEvent] = [.sujoodCounted(sujoodInCurrentRakaat)]
        if sujoodInCurrentRakaat >= 2 {
            sujoodInCurrentRakaat = 0
            events += completeRakaat()
        }
        return events
    }

    private mutating func completeRakaat() -> [RakaatEvent] {
        completedRakaat += 1
        var events: [RakaatEvent] = [.rakaatCompleted(completedRakaat)]
        let isLast = completedRakaat >= rakaatCount
        if prayer.tashahhudRakaat.contains(completedRakaat) {
            events.append(.tashahhud(isFinal: isLast))
        }
        if isLast {
            events.append(.prayerCompleted)
        }
        return events
    }

    private mutating func clearSujood() {
        nearStart = nil
        pendingEnd = nil
    }
}
