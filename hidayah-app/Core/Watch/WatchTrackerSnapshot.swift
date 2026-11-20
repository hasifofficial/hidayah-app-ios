//
//  WatchTrackerSnapshot.swift
//  hidayah-app
//

import Foundation

/// Today's tracker as the iPhone sends it to the Watch. The iPhone owns the
/// tracker; the Watch only shows this and asks for changes.
struct WatchTrackerSnapshot: Codable, Equatable {
    /// The tracker day these tasks belong to.
    let dayKey: String
    let tasks: [TaskDetails]
    let currentStreak: Int
    /// When the next tracker day starts, and its key, so the Watch can show
    /// a fresh day before it hears from the iPhone again.
    let nextDayStart: Date?
    let nextDayKey: String?
    /// When the day after that starts. Past it the Watch cannot tell which
    /// day it is, so it waits for the iPhone.
    let nextDayEnd: Date?
    /// When the iPhone made this snapshot. A tap the Watch sent before this
    /// has been seen by the iPhone, so the snapshot settles it either way.
    var generatedAt: Date? = nil
}

extension WatchTrackerSnapshot {
    /// Equal apart from when it was made, so an unchanged tracker is not
    /// sent again.
    func hasSameContent(as other: WatchTrackerSnapshot?) -> Bool {
        guard var other else { return false }
        other.generatedAt = generatedAt
        return other == self
    }
}

/// A request from the Watch to set one task's completion. It carries the
/// value rather than "toggle", so a request delivered twice changes nothing.
struct WatchTaskCompletion: Codable, Equatable {
    let taskID: UUID
    let isCompleted: Bool
    let dayKey: String
}

/// Keys and coding for the WatchConnectivity payloads both sides exchange.
enum WatchMessage {
    static let snapshotKey = "trackerSnapshot"
    static let completionKey = "taskCompletion"
    static let requestSnapshotKey = "requestSnapshot"

    static func payload(for snapshot: WatchTrackerSnapshot) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(snapshot) else { return nil }
        return [snapshotKey: data]
    }

    static func payload(for completion: WatchTaskCompletion) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(completion) else { return nil }
        return [completionKey: data]
    }

    static func snapshot(from payload: [String: Any]) -> WatchTrackerSnapshot? {
        guard let data = payload[snapshotKey] as? Data else { return nil }
        return try? JSONDecoder().decode(WatchTrackerSnapshot.self, from: data)
    }

    static func completion(from payload: [String: Any]) -> WatchTaskCompletion? {
        guard let data = payload[completionKey] as? Data else { return nil }
        return try? JSONDecoder().decode(WatchTaskCompletion.self, from: data)
    }
}
