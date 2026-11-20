//
//  WatchSyncService.swift
//  hidayah-app
//

import Foundation
import WatchConnectivity

/// The iPhone side of the Watch link. Sends the tracker to the Watch after
/// every change and applies completions the Watch asks for. iPhone only.
@MainActor
final class WatchSyncService: NSObject {
    static let shared = WatchSyncService(
        session: !AppEnvironment.isRunningUnitTests && WCSession.isSupported()
            ? .default
            : nil
    )

    private let session: WCSession?
    private let now: () -> Date
    private weak var taskManager: TaskManager?
    private var lastSentSnapshot: WatchTrackerSnapshot?

    init(
        session: WCSession?,
        now: @escaping () -> Date = Date.init
    ) {
        self.session = session
        self.now = now
        super.init()
    }

    /// Connects to `taskManager` and starts the session.
    func start(taskManager: TaskManager) {
        self.taskManager = taskManager
        taskManager.onTrackerChange = { [weak self] in
            self?.sendSnapshot()
        }

        guard let session else { return }
        session.delegate = self
        session.activate()
    }

    /// Applies a completion from the Watch, then always answers with a fresh
    /// snapshot so the Watch drops the tap whether or not it took effect.
    func handle(_ completion: WatchTaskCompletion) {
        guard let taskManager else { return }
        let changed = taskManager.setTaskCompletion(
            taskID: completion.taskID,
            isCompleted: completion.isCompleted,
            dayKey: completion.dayKey
        )
        if !changed {
            sendSnapshot(force: true)
        }
    }

    func makeSnapshot() -> WatchTrackerSnapshot? {
        guard let taskManager else { return nil }
        return Self.makeSnapshot(from: taskManager, now: now())
    }

    static func makeSnapshot(
        from taskManager: TaskManager,
        now: Date
    ) -> WatchTrackerSnapshot {
        let nextDayStart = TrackerDayKey.nextDayStart(after: now)
        return WatchTrackerSnapshot(
            dayKey: taskManager.activeDayKey ?? TrackerDayKey.today(now: now),
            tasks: taskManager.tasks,
            currentStreak: taskManager.stats.currentStreak,
            nextDayStart: nextDayStart,
            nextDayKey: nextDayStart.map { TrackerDayKey.today(now: $0) },
            nextDayEnd: nextDayStart.flatMap { TrackerDayKey.nextDayStart(after: $0) },
            generatedAt: now
        )
    }

    private func sendSnapshot(force: Bool = false) {
        guard let session,
              session.activationState == .activated,
              session.isPaired,
              session.isWatchAppInstalled,
              let snapshot = makeSnapshot(),
              force || !snapshot.hasSameContent(as: lastSentSnapshot),
              let payload = WatchMessage.payload(for: snapshot) else {
            return
        }

        do {
            // The latest context survives until the Watch app next runs.
            try session.updateApplicationContext(payload)
            lastSentSnapshot = snapshot
        } catch {
            #if DEBUG
            print("Watch context update failed: \(error.localizedDescription)")
            #endif
        }

        // Context delivery can lag; a live message reaches an open app now.
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.sendSnapshot(force: true)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // The user switched watches; start talking to the new one.
        session.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.sendSnapshot(force: true)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        guard let completion = WatchMessage.completion(from: userInfo) else { return }
        Task { @MainActor in
            self.handle(completion)
        }
    }

    /// A message sent without a reply handler arrives here, not in the
    /// variant below. Without this method WatchConnectivity drops it.
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        guard let completion = WatchMessage.completion(from: message) else { return }
        Task { @MainActor in
            self.handle(completion)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        if let completion = WatchMessage.completion(from: message) {
            // Reply with the result so the Watch can settle the tap now.
            Task { @MainActor in
                self.handle(completion)
                let payload = self.makeSnapshot().flatMap(WatchMessage.payload(for:))
                replyHandler(payload ?? [:])
            }
            return
        }

        guard message[WatchMessage.requestSnapshotKey] != nil else {
            replyHandler([:])
            return
        }
        Task { @MainActor in
            let payload = self.makeSnapshot().flatMap(WatchMessage.payload(for:))
            replyHandler(payload ?? [:])
        }
    }
}
