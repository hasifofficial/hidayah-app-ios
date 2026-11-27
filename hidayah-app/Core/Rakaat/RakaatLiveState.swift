//
//  RakaatLiveState.swift
//  hidayah-app
//

import Foundation

/// The iPhone's rakaat session as it sends it to the Watch, which shows the
/// count and plays the cues on the wrist.
struct RakaatLiveState: Codable, Equatable {
    let sessionID: UUID
    let prayer: RakaatPrayer
    let completedRakaat: Int
    let sujoodInCurrentRakaat: Int
    /// False once the iPhone has stopped the session.
    let isActive: Bool
    /// Goes up with every update in a session, so the Watch plays each
    /// update's cues once even if it is delivered twice.
    let sequence: Int
    /// What happened in this update, for the Watch's haptics.
    let events: [RakaatEvent]
    let updatedAt: Date

    /// A session the iPhone hasn't updated for this long is treated as
    /// abandoned, so an old context doesn't bring back a finished prayer.
    static let staleInterval: TimeInterval = 20 * 60

    func isStale(now: Date) -> Bool {
        now.timeIntervalSince(updatedAt) > Self.staleInterval
    }
}

/// A correction from the Watch for the iPhone's live session.
struct RakaatCommand: Codable, Equatable {
    enum Action: String, Codable {
        case increment
        case decrement
    }

    let sessionID: UUID
    let action: Action
}

extension WatchMessage {
    static let rakaatStateKey = "rakaatLiveState"
    static let rakaatCommandKey = "rakaatCommand"

    static func payload(for state: RakaatLiveState) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(state) else { return nil }
        return [rakaatStateKey: data]
    }

    static func payload(for command: RakaatCommand) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(command) else { return nil }
        return [rakaatCommandKey: data]
    }

    static func rakaatState(from payload: [String: Any]) -> RakaatLiveState? {
        guard let data = payload[rakaatStateKey] as? Data else { return nil }
        return try? JSONDecoder().decode(RakaatLiveState.self, from: data)
    }

    static func rakaatCommand(from payload: [String: Any]) -> RakaatCommand? {
        guard let data = payload[rakaatCommandKey] as? Data else { return nil }
        return try? JSONDecoder().decode(RakaatCommand.self, from: data)
    }
}
