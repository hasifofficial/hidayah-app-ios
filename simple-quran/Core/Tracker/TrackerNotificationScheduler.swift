//
//  TrackerNotificationScheduler.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import UserNotifications

/// The parts of `UNUserNotificationCenter` the tracker uses, so tests can
/// observe scheduling without posting real notifications.
@MainActor
protocol NotificationScheduling: AnyObject {
    func schedule(_ request: UNNotificationRequest)
    func removePending(identifiers: [String])
    func pendingIdentifiers() async -> [String]
}

extension UNUserNotificationCenter: NotificationScheduling {
    func schedule(_ request: UNNotificationRequest) {
        add(request)
    }

    func removePending(identifiers: [String]) {
        removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func pendingIdentifiers() async -> [String] {
        await pendingNotificationRequests().map(\.identifier)
    }
}

@MainActor
final class TrackerNotificationScheduler {
    static let shared = TrackerNotificationScheduler()

    private let center: NotificationScheduling
    private let milestones = [25, 50, 75, 100]

    init(center: NotificationScheduling = UNUserNotificationCenter.current()) {
        self.center = center
    }

    /// The app's own bundle, also when this runs in the widget: ticking a
    /// task from the Tracker widget schedules cheers from the extension,
    /// whose bundle has only the widget's strings.
    static let stringsBundle: Bundle = {
        Bundle(url: appBundleURL(for: Bundle.main.bundleURL)) ?? .main
    }()

    /// `App.app/PlugIns/Widget.appex` → `App.app`; any other URL is
    /// returned unchanged.
    nonisolated static func appBundleURL(for bundleURL: URL) -> URL {
        guard bundleURL.pathExtension == "appex" else { return bundleURL }
        return bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: stringsBundle, comment: "")
    }

    private var isEnabled: Bool {
        Storage.load(key: .allowTrackerCheerleader) as? Bool ?? true
    }

    func syncDailyCheer() {
        center.removePending(
            identifiers: [NotificationIdentifier.trackerDailyCheer.rawValue]
        )

        guard isEnabled else {
            clearMilestones()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = Self.localized("push_notification_tracker_cheer_title")
        content.body = Self.localized("push_notification_tracker_cheer_body")
        content.sound = .default
        content.userInfo = [
            "url": "hidayahapp://inAppDeeplink/tracker"
        ]

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.trackerDailyCheer.rawValue,
            content: content,
            trigger: trigger
        )
        center.schedule(request)
    }

    func progressDidChange(
        record: TrackerDayRecord?,
        stats: TrackerStats
    ) {
        guard isEnabled, let record, record.totalCount > 0 else { return }

        var state = loadState()
        if state.dayKey != record.dayKey {
            state = TrackerCheerState(dayKey: record.dayKey)
        }

        let percent = Int((record.progress * 100).rounded())
        let newlyReached = milestones.filter {
            percent >= $0 && !state.sentMilestones.contains($0)
        }

        guard let highest = newlyReached.max() else { return }

        // Mark all crossed thresholds as sent, but only show one cheer.
        state.sentMilestones.formUnion(newlyReached)
        scheduleMilestone(
            highest,
            record: record,
            stats: stats
        )
        save(state)
    }

    func clearMilestones() {
        let prefix = NotificationIdentifier.trackerMilestonePrefix
        Task {
            let identifiers = await center.pendingIdentifiers()
                .filter { $0.hasPrefix(prefix) }
            center.removePending(identifiers: identifiers)
        }
        Storage.delete(.trackerCheerState)
    }

    func clearAll() {
        center.removePending(
            identifiers: [NotificationIdentifier.trackerDailyCheer.rawValue]
        )
        clearMilestones()
    }

    private func scheduleMilestone(
        _ milestone: Int,
        record: TrackerDayRecord,
        stats: TrackerStats
    ) {
        let content = UNMutableNotificationContent()
        content.title = Self.localized("push_notification_tracker_cheer_title")

        if milestone == 100 {
            content.body = String(
                format: Self.localized("push_notification_tracker_cheer_complete_body"),
                stats.currentStreak,
                stats.level
            )
        } else {
            content.body = String(
                format: Self.localized("push_notification_tracker_cheer_milestone_body"),
                milestone
            )
        }

        content.sound = .default
        content.userInfo = [
            "url": "hidayahapp://inAppDeeplink/tracker"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let identifier = NotificationIdentifier.trackerMilestonePrefix
            + "\(record.dayKey)-\(milestone)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        center.schedule(request)
    }

    private func loadState() -> TrackerCheerState {
        Storage.loadObject(key: .trackerCheerState)
            ?? TrackerCheerState()
    }

    private func save(_ state: TrackerCheerState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        Storage.save(.trackerCheerState, data)
    }
}
