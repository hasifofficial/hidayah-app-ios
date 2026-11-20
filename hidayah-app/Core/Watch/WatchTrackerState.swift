//
//  WatchTrackerState.swift
//  hidayah-app
//

import Foundation

/// What the Watch shows for the tracker: the iPhone's latest snapshot, with
/// the Watch's own taps laid on top until the iPhone confirms them.
///
/// Plain value logic with an injected `now`, so it is tested in the iPhone
/// test target.
struct WatchTrackerState: Codable, Equatable {
    /// A tap on the Watch the iPhone has not answered yet.
    struct PendingCompletion: Codable, Equatable {
        let isCompleted: Bool
        let sentAt: Date
    }

    private(set) var snapshot: WatchTrackerSnapshot?
    /// Completions tapped on the Watch that the iPhone has not answered.
    private(set) var pending: [UUID: PendingCompletion] = [:]
    /// The tracker day `pending` belongs to.
    private(set) var pendingDayKey: String?

    init(snapshot: WatchTrackerSnapshot? = nil) {
        self.snapshot = snapshot
    }

    // MARK: Reading

    /// The tracker day at `now`, or nil when the snapshot is too old to
    /// tell (or there is none yet).
    func dayKey(now: Date) -> String? {
        guard let snapshot else { return nil }
        guard let nextDayStart = snapshot.nextDayStart, now >= nextDayStart else {
            return snapshot.dayKey
        }
        guard let nextDayEnd = snapshot.nextDayEnd, now < nextDayEnd else {
            return nil
        }
        return snapshot.nextDayKey
    }

    /// True once the snapshot's day has passed, so its completions no
    /// longer apply.
    func hasRolledOver(now: Date) -> Bool {
        guard let nextDayStart = snapshot?.nextDayStart else { return false }
        return now >= nextDayStart
    }

    /// True when the Watch cannot tell which day it is and should wait for
    /// the iPhone before accepting taps.
    func isStale(now: Date) -> Bool {
        snapshot != nil && dayKey(now: now) == nil
    }

    func tasks(now: Date) -> [TaskDetails] {
        guard let snapshot else { return [] }
        let rolledOver = hasRolledOver(now: now)
        let applyPending = pendingDayKey != nil && pendingDayKey == dayKey(now: now)

        return snapshot.tasks.map { task in
            var task = task
            if rolledOver {
                task.isCompleted = false
            }
            if applyPending, let tap = pending[task.id] {
                task.isCompleted = tap.isCompleted
            }
            return task
        }
    }

    func progress(now: Date) -> (completed: Int, total: Int) {
        let tasks = tasks(now: now)
        return (tasks.filter(\.isCompleted).count, tasks.count)
    }

    // MARK: Changing

    /// Records a tap on the Watch and returns the request to send to the
    /// iPhone, or nil when the day is unknown or the task is not shown.
    mutating func setCompletion(
        taskID: UUID,
        isCompleted: Bool,
        now: Date
    ) -> WatchTaskCompletion? {
        guard let dayKey = dayKey(now: now),
              snapshot?.tasks.contains(where: { $0.id == taskID }) == true else {
            return nil
        }

        if pendingDayKey != dayKey {
            pending = [:]
            pendingDayKey = dayKey
        }
        pending[taskID] = PendingCompletion(isCompleted: isCompleted, sentAt: now)
        return WatchTaskCompletion(
            taskID: taskID,
            isCompleted: isCompleted,
            dayKey: dayKey
        )
    }

    /// Takes a new snapshot from the iPhone. A tap is settled, and the
    /// snapshot shown as it is, when the snapshot already reflects it, was
    /// made after the tap was sent (so the iPhone has seen it, applied or
    /// not), or has moved past the tap's day.
    mutating func apply(_ newSnapshot: WatchTrackerSnapshot) {
        snapshot = newSnapshot

        guard let pendingDayKey else { return }

        if pendingDayKey == newSnapshot.dayKey {
            let tasksByID = Dictionary(
                newSnapshot.tasks.map { ($0.id, $0.isCompleted) },
                uniquingKeysWith: { first, _ in first }
            )
            pending = pending.filter { id, tap in
                guard let current = tasksByID[id], current != tap.isCompleted else {
                    return false
                }
                return !Self.hasSeen(tap, newSnapshot)
            }
        } else if pendingDayKey < newSnapshot.dayKey {
            // Day keys are yyyy-MM-dd, so they sort by date.
            pending = [:]
        } else {
            // A later pending day means the Watch rolled over before the
            // iPhone did; keep those taps until the iPhone has seen them.
            pending = pending.filter { !Self.hasSeen($0.value, newSnapshot) }
        }

        if pending.isEmpty {
            self.pendingDayKey = nil
        }
    }

    /// Settles one tap the iPhone has answered directly, then shows the
    /// snapshot it answered with.
    mutating func settle(taskID: UUID, with newSnapshot: WatchTrackerSnapshot?) {
        pending[taskID] = nil
        if pending.isEmpty {
            pendingDayKey = nil
        }
        if let newSnapshot {
            apply(newSnapshot)
        }
    }

    private static func hasSeen(
        _ tap: PendingCompletion,
        _ snapshot: WatchTrackerSnapshot
    ) -> Bool {
        guard let generatedAt = snapshot.generatedAt else { return false }
        return generatedAt >= tap.sentAt
    }
}
