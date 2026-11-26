//
//  WatchTrackerModel.swift
//  hidayah-app-watch
//

import Foundation
import Observation
import WatchConnectivity

/// The Watch side of the tracker link. Keeps the iPhone's latest snapshot
/// (saved so it shows straight away on launch) and sends taps back.
@MainActor
@Observable
final class WatchTrackerModel: NSObject {
    private(set) var state: WatchTrackerState

    @ObservationIgnored private let session: WCSession?
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private static let stateKey = "watchTrackerState"
    /// Receives the iPhone's live rakaat session. The session has one
    /// delegate, so rakaat updates come through here.
    @ObservationIgnored var onRakaatState: ((RakaatLiveState) -> Void)?

    init(
        session: WCSession? = WCSession.isSupported() ? .default : nil,
        defaults: UserDefaults = .standard
    ) {
        self.session = session
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.stateKey),
           let saved = try? JSONDecoder().decode(WatchTrackerState.self, from: data) {
            state = saved
        } else {
            state = WatchTrackerState()
        }
        super.init()
    }

    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
    }

    /// Asks the iPhone for a fresh snapshot when it is reachable.
    func refresh() {
        guard let session,
              session.activationState == .activated,
              session.isReachable else {
            return
        }
        session.sendMessage(
            [WatchMessage.requestSnapshotKey: true],
            replyHandler: { reply in
                guard let snapshot = WatchMessage.snapshot(from: reply) else { return }
                Task { @MainActor in
                    self.apply(snapshot)
                }
            },
            errorHandler: nil
        )
    }

    func toggle(_ task: TaskDetails, now: Date = Date()) {
        guard let completion = state.setCompletion(
            taskID: task.id,
            isCompleted: !task.isCompleted,
            now: now
        ) else {
            return
        }
        AppHaptics.tap()
        save()
        send(completion)
    }

    /// Sends a rakaat correction to the iPhone's live session. Only a live
    /// message is useful: a queued one would arrive after the prayer.
    func send(_ command: RakaatCommand) {
        guard let session,
              session.activationState == .activated,
              session.isReachable,
              let payload = WatchMessage.payload(for: command) else {
            return
        }
        session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }

    private func settle(_ completion: WatchTaskCompletion, with snapshot: WatchTrackerSnapshot?) {
        state.settle(taskID: completion.taskID, with: snapshot)
        save()
    }

    private func send(_ completion: WatchTaskCompletion) {
        guard let session,
              let payload = WatchMessage.payload(for: completion) else {
            return
        }

        // A live message is quicker; the queued transfer is delivered even
        // if the iPhone is away, and requests are safe to apply twice.
        if session.activationState == .activated, session.isReachable {
            // Ask for a reply so a failure on the iPhone's side also reaches
            // the error handler, and the tap falls back to the queue.
            session.sendMessage(
                payload,
                replyHandler: { reply in
                    // The iPhone has dealt with the tap; its reply is the
                    // tracker as it now stands.
                    let snapshot = WatchMessage.snapshot(from: reply)
                    Task { @MainActor in
                        self.settle(completion, with: snapshot)
                    }
                },
                errorHandler: { _ in session.transferUserInfo(payload) }
            )
        } else {
            session.transferUserInfo(payload)
        }
    }

    private func apply(_ snapshot: WatchTrackerSnapshot) {
        state.apply(snapshot)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.stateKey)
        }
    }
}

extension WatchTrackerModel: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let context = session.receivedApplicationContext
        let snapshot = WatchMessage.snapshot(from: context)
        let rakaat = WatchMessage.rakaatState(from: context)
        Task { @MainActor in
            if let snapshot {
                self.apply(snapshot)
            }
            if let rakaat {
                self.onRakaatState?(rakaat)
            }
            self.refresh()
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let snapshot = WatchMessage.snapshot(from: applicationContext)
        let rakaat = WatchMessage.rakaatState(from: applicationContext)
        Task { @MainActor in
            if let snapshot {
                self.apply(snapshot)
            }
            if let rakaat {
                self.onRakaatState?(rakaat)
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        if let rakaat = WatchMessage.rakaatState(from: message) {
            Task { @MainActor in
                self.onRakaatState?(rakaat)
            }
            return
        }
        guard let snapshot = WatchMessage.snapshot(from: message) else { return }
        Task { @MainActor in
            self.apply(snapshot)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable else { return }
        Task { @MainActor in
            self.refresh()
        }
    }
}
