//
//  WidgetTestSupport.swift
//  app-widgetTests
//

import Foundation
import SwiftData
import UserNotifications
import WidgetKit
import XCTest

// MARK: - Store and preferences

/// Clears every key the widget and the app write, so each test starts from
/// defaults.
func resetStorage() {
    Storage.StorageKey.allCases.forEach { Storage.delete($0) }
}

struct StoreUnavailableError: Error, Equatable {}

/// A store whose on-disk container never opens, like the widget's store when
/// the App Group is unavailable.
@MainActor
func makeUnavailableStore() -> HidayahStore {
    HidayahStore(makeContainer: { throw StoreUnavailableError() })
}

// MARK: - Dates

/// A date in the tracker calendar, so day keys do not depend on the
/// simulator's time zone.
func trackerDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 12,
    minute: Int = 0
) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    return TrackerDayKey.calendar.date(from: components)!
}

// MARK: - Fixtures

func makeTask(
    _ name: String,
    isCompleted: Bool = false
) -> TaskDetails {
    TaskDetails(
        name: name,
        category: .default(.fajr),
        isCompleted: isCompleted
    )
}

func makeEntry(
    date: Date = trackerDate(year: 2026, month: 11, day: 3),
    progress: Double = 0.5,
    completed: Int = 1,
    total: Int = 2,
    upcoming: [TaskDetails] = []
) -> TrackerEntry {
    TrackerEntry(
        date: date,
        progress: progress,
        completedTasks: completed,
        totalTasks: total,
        upcomingTasks: upcoming
    )
}

// MARK: - Notifications

@MainActor
final class FakeNotificationCenter: NotificationScheduling {
    private(set) var scheduled: [UNNotificationRequest] = []
    private(set) var removed: [[String]] = []

    func schedule(_ request: UNNotificationRequest) {
        scheduled.append(request)
    }

    func removePending(identifiers: [String]) {
        removed.append(identifiers)
    }

    func pendingIdentifiers() async -> [String] {
        scheduled.map(\.identifier)
    }
}
