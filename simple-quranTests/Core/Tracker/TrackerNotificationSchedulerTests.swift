//
//  TrackerNotificationSchedulerTests.swift
//  simple-quranTests
//

import UserNotifications
import XCTest
@testable import simple_quran

@MainActor
final class TrackerNotificationSchedulerTests: XCTestCase {
    private var center: FakeNotificationCenter!
    private var sut: TrackerNotificationScheduler!

    private let dailyID = NotificationIdentifier.trackerDailyCheer.rawValue
    private let prefix = NotificationIdentifier.trackerMilestonePrefix
    private let now = TestClock.date(year: 2026, month: 3, day: 10)

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        center = FakeNotificationCenter()
        sut = TrackerNotificationScheduler(center: center)
    }

    override func tearDown() async throws {
        resetStorage()
        center = nil
        sut = nil
        try await super.tearDown()
    }

    private func stats(for record: TrackerDayRecord) -> TrackerStats {
        TrackerStats(records: [record], now: now)
    }

    private func loadState() -> TrackerCheerState? {
        Storage.loadObject(key: .trackerCheerState)
    }

    // MARK: - Daily cheer

    func test_syncDailyCheer_should_scheduleRepeatingEveningReminder() throws {
        // Arrange
        Storage.save(.allowTrackerCheerleader, true)

        // Act
        sut.syncDailyCheer()

        // Assert
        XCTAssertEqual(center.removed, [[dailyID]])
        let request = try XCTUnwrap(center.scheduled.first)
        XCTAssertEqual(center.scheduled.count, 1)
        XCTAssertEqual(request.identifier, dailyID)
        XCTAssertEqual(request.content.title, "Istiqamah Reminder")
        XCTAssertEqual(request.content.userInfo["url"] as? String, "hidayahapp://inAppDeeplink/tracker")
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.hour, 20)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
    }

    func test_syncDailyCheer_should_beEnabledByDefault() {
        // Arrange
        Storage.delete(.allowTrackerCheerleader)

        // Act
        sut.syncDailyCheer()

        // Assert
        XCTAssertEqual(center.scheduled.map(\.identifier), [dailyID])
    }

    func test_syncDailyCheer_should_clearEverythingWhenDisabled() async {
        // Arrange
        Storage.save(.allowTrackerCheerleader, false)
        Storage.save(.trackerCheerState, Data("{}".utf8))
        center.pending = [prefix + "2026-03-10-25", dailyID]

        // Act
        sut.syncDailyCheer()

        // Assert
        await waitUntil { self.center.removed.count == 2 }
        XCTAssertTrue(center.scheduled.isEmpty)
        XCTAssertEqual(center.removed.last, [prefix + "2026-03-10-25"])
        XCTAssertNil(Storage.load(key: .trackerCheerState))
    }

    // MARK: - Milestones

    func test_progressDidChange_should_scheduleHighestNewMilestoneOnly() throws {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 2, total: 4)

        // Act
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Assert
        let request = try XCTUnwrap(center.scheduled.first)
        XCTAssertEqual(center.scheduled.count, 1)
        XCTAssertEqual(request.identifier, prefix + "2026-03-10-50")
        XCTAssertEqual(request.content.body, "You're 50% through today's tracker. Keep going!")
        XCTAssertEqual(request.content.userInfo["url"] as? String, "hidayahapp://inAppDeeplink/tracker")
        XCTAssertFalse(try XCTUnwrap(request.trigger as? UNTimeIntervalNotificationTrigger).repeats)
        XCTAssertEqual(loadState()?.sentMilestones, [25, 50])
        XCTAssertEqual(loadState()?.dayKey, "2026-03-10")
    }

    func test_progressDidChange_should_sendEachMilestoneOncePerDay() {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 2, total: 4)
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Act
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Assert
        XCTAssertEqual(center.scheduled.count, 1)
    }

    func test_progressDidChange_should_sendNextMilestoneWhenReached() {
        // Arrange
        let half = makeRecord("2026-03-10", completed: 2, total: 4)
        sut.progressDidChange(record: half, stats: stats(for: half))
        let threeQuarters = makeRecord("2026-03-10", completed: 3, total: 4)

        // Act
        sut.progressDidChange(record: threeQuarters, stats: stats(for: threeQuarters))

        // Assert
        XCTAssertEqual(
            center.scheduled.map(\.identifier),
            [prefix + "2026-03-10-50", prefix + "2026-03-10-75"]
        )
        XCTAssertEqual(loadState()?.sentMilestones, [25, 50, 75])
    }

    func test_progressDidChange_should_sendCompletionCheerWithStreakAndLevel() throws {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 2, total: 2)

        // Act
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Assert
        let request = try XCTUnwrap(center.scheduled.first)
        XCTAssertEqual(request.identifier, prefix + "2026-03-10-100")
        XCTAssertEqual(
            request.content.body,
            "Alhamdulillah! You completed everything today. 1-day streak, Level 1."
        )
        XCTAssertEqual(loadState()?.sentMilestones, [25, 50, 75, 100])
    }

    func test_progressDidChange_should_startFreshOnNewDay() {
        // Arrange
        let yesterday = makeRecord("2026-03-09", completed: 2, total: 4)
        sut.progressDidChange(record: yesterday, stats: stats(for: yesterday))
        let today = makeRecord("2026-03-10", completed: 1, total: 4)

        // Act
        sut.progressDidChange(record: today, stats: stats(for: today))

        // Assert
        XCTAssertEqual(center.scheduled.last?.identifier, prefix + "2026-03-10-25")
        XCTAssertEqual(loadState()?.dayKey, "2026-03-10")
        XCTAssertEqual(loadState()?.sentMilestones, [25])
    }

    func test_progressDidChange_should_doNothingBelowFirstMilestone() {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 1, total: 5)

        // Act
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Assert
        XCTAssertTrue(center.scheduled.isEmpty)
        XCTAssertNil(loadState())
    }

    func test_progressDidChange_should_doNothingWhenDisabled() {
        // Arrange
        Storage.save(.allowTrackerCheerleader, false)
        let record = makeRecord("2026-03-10", completed: 2, total: 2)

        // Act
        sut.progressDidChange(record: record, stats: stats(for: record))

        // Assert
        XCTAssertTrue(center.scheduled.isEmpty)
    }

    func test_progressDidChange_should_ignoreMissingOrEmptyRecord() {
        // Arrange
        let empty = TrackerDayRecord(dayKey: "2026-03-10", tasks: [])

        // Act
        sut.progressDidChange(record: nil, stats: stats(for: empty))
        sut.progressDidChange(record: empty, stats: stats(for: empty))

        // Assert
        XCTAssertTrue(center.scheduled.isEmpty)
    }

    // MARK: - Clearing

    func test_clearMilestones_should_removeOnlyPendingMilestones() async {
        // Arrange
        center.pending = [prefix + "2026-03-10-25", prefix + "2026-03-10-50", dailyID, "other"]
        Storage.save(.trackerCheerState, Data("{}".utf8))

        // Act
        sut.clearMilestones()

        // Assert
        await waitUntil { !self.center.removed.isEmpty }
        XCTAssertEqual(center.removed, [[prefix + "2026-03-10-25", prefix + "2026-03-10-50"]])
        XCTAssertEqual(center.pending, [dailyID, "other"])
        XCTAssertNil(Storage.load(key: .trackerCheerState))
    }

    func test_clearAll_should_removeDailyCheerAndMilestones() async {
        // Arrange
        center.pending = [prefix + "2026-03-10-25", dailyID]

        // Act
        sut.clearAll()

        // Assert
        await waitUntil { self.center.removed.count == 2 }
        XCTAssertEqual(center.removed.first, [dailyID])
        XCTAssertTrue(center.pending.isEmpty)
    }

    // MARK: Strings bundle
    //
    // Ticking a task in the Tracker widget schedules cheers from the widget
    // extension, whose bundle lacks these strings, so the scheduler reads
    // them from the containing app.

    func test_appBundleURL_should_resolveContainingApp_when_runningInWidget() {
        // Arrange
        let widget = URL(fileURLWithPath: "/Containers/Hidayah.app/PlugIns/app-widgetExtension.appex")

        // Act
        let app = TrackerNotificationScheduler.appBundleURL(for: widget)

        // Assert
        XCTAssertEqual(app.path, "/Containers/Hidayah.app")
    }

    func test_appBundleURL_should_keepURL_when_runningInApp() {
        // Arrange
        let appURL = URL(fileURLWithPath: "/Containers/Hidayah.app")

        // Act
        let resolved = TrackerNotificationScheduler.appBundleURL(for: appURL)

        // Assert
        XCTAssertEqual(resolved, appURL)
    }

    func test_stringsBundle_should_holdEveryCheerString() {
        // Arrange
        let keys = [
            "push_notification_tracker_cheer_title",
            "push_notification_tracker_cheer_body",
            "push_notification_tracker_cheer_milestone_body",
            "push_notification_tracker_cheer_complete_body"
        ]

        // Act
        let missing = keys.filter {
            NSLocalizedString($0, bundle: TrackerNotificationScheduler.stringsBundle, comment: "") == $0
        }

        // Assert
        XCTAssertTrue(missing.isEmpty, "\(missing)")
    }

    func test_shared_should_exist() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let shared = TrackerNotificationScheduler.shared

        // Assert
        XCTAssertTrue(shared === TrackerNotificationScheduler.shared)
    }

    func test_systemCenter_should_dropRequestAfterRemovingIt() async {
        // Arrange
        let center: NotificationScheduling = UNUserNotificationCenter.current()
        let identifier = "com.hasifofficial.simple-quran.tests.\(UUID().uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: UNMutableNotificationContent(),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3_600, repeats: false)
        )
        center.schedule(request)

        // Act
        center.removePending(identifiers: [identifier])
        let pending = await center.pendingIdentifiers()

        // Assert
        XCTAssertFalse(pending.contains(identifier))
    }
}
