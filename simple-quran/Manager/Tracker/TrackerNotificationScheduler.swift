//
//  TrackerNotificationScheduler.swift
//  simple-quran
//

import Foundation
import UserNotifications

final class TrackerNotificationScheduler {
    static let shared = TrackerNotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let milestones = [25, 50, 75, 100]

    private init() {}

    private var isEnabled: Bool {
        Storage.load(key: .allowTrackerCheerleader) as? Bool ?? true
    }

    func syncDailyCheer() {
        center.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.trackerDailyCheer.rawValue]
        )

        guard isEnabled else {
            clearMilestones()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(
            "push_notification_tracker_cheer_title",
            comment: ""
        )
        content.body = NSLocalizedString(
            "push_notification_tracker_cheer_body",
            comment: ""
        )
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
        center.add(request)
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
        center.getPendingNotificationRequests { [weak self] requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }
            self?.center.removePendingNotificationRequests(
                withIdentifiers: identifiers
            )
        }
        Storage.delete(.trackerCheerState)
    }

    func clearAll() {
        center.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.trackerDailyCheer.rawValue]
        )
        clearMilestones()
    }

    private func scheduleMilestone(
        _ milestone: Int,
        record: TrackerDayRecord,
        stats: TrackerStats
    ) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(
            "push_notification_tracker_cheer_title",
            comment: ""
        )

        if milestone == 100 {
            content.body = String(
                format: NSLocalizedString(
                    "push_notification_tracker_cheer_complete_body",
                    comment: ""
                ),
                stats.currentStreak,
                stats.level
            )
        } else {
            content.body = String(
                format: NSLocalizedString(
                    "push_notification_tracker_cheer_milestone_body",
                    comment: ""
                ),
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
        center.add(request)
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
