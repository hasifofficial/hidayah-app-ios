//
//  AppControllerTests.swift
//  simple-quranTests
//

import UIKit
import UserNotifications
import XCTest
@testable import simple_quran

@MainActor
final class AppControllerTests: XCTestCase {
    private var center: FakeNotificationCenter!
    private var clock: TestClock!
    private var previousDelegate: UNUserNotificationCenterDelegate?

    private let kahfID = NotificationIdentifier.kahfReminder.rawValue
    private let dailyID = NotificationIdentifier.trackerDailyCheer.rawValue

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        center = FakeNotificationCenter()
        clock = TestClock(TestClock.date(year: 2026, month: 3, day: 10))
        previousDelegate = UNUserNotificationCenter.current().delegate
    }

    override func tearDown() async throws {
        UNUserNotificationCenter.current().delegate = previousDelegate
        resetStorage()
        center = nil
        clock = nil
        try await super.tearDown()
    }

    private func makeSUT(store: HidayahStore? = nil) -> AppController {
        let store = store ?? makeInMemoryStore()
        return AppController(
            taskManager: makeTaskManager(store: store, center: center, clock: clock),
            store: store,
            scheduler: TrackerNotificationScheduler(center: center),
            notificationCenter: center
        )
    }

    // MARK: - Launch

    func test_init_should_scheduleWeeklyKahfReminderByDefault() throws {
        // Arrange
        Storage.delete(.allowKahfReminder)

        // Act
        _ = makeSUT()

        // Assert
        let request = try XCTUnwrap(center.scheduled.first { $0.identifier == kahfID })
        XCTAssertEqual(request.content.title, "Al-Kahf Reminder")
        XCTAssertEqual(request.content.userInfo["url"] as? String, "hidayahapp://inAppDeeplink/quran/18")
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.weekday, 6)
        XCTAssertEqual(trigger.dateComponents.hour, 9)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
    }

    func test_init_should_removeKahfReminderWhenDisabled() {
        // Arrange
        Storage.save(.allowKahfReminder, false)

        // Act
        _ = makeSUT()

        // Assert
        XCTAssertFalse(center.scheduled.contains { $0.identifier == kahfID })
        XCTAssertTrue(center.removed.contains([kahfID]))
    }

    func test_init_should_syncTrackerDailyCheer() {
        // Arrange
        Storage.delete(.allowTrackerCheerleader)

        // Act
        _ = makeSUT()

        // Assert
        XCTAssertTrue(center.scheduled.contains { $0.identifier == dailyID })
    }

    func test_init_should_becomeNotificationDelegate() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertTrue(UNUserNotificationCenter.current().delegate === sut)
    }

    func test_init_should_leaveErrorMessageEmptyWhenStoreOpens() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertNil(sut.router.errorMessage)
    }

    func test_init_should_showAlertWhenStoreFailedToOpen() {
        // Arrange
        let store = makeFailingStore()

        // Act
        let sut = makeSUT(store: store)

        // Assert
        XCTAssertEqual(
            sut.router.errorMessage,
            "Your saved data couldn't be opened. Changes you make now won't be saved. Please restart the app, and contact us if this keeps happening."
        )
    }

    func test_init_should_exposeSharedServices() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertTrue(sut.surahService === sut.surahService)
        XCTAssertTrue(sut.deeplinkManager === sut.deeplinkManager)
        XCTAssertEqual(sut.taskManager.activeDayKey, "2026-03-10")
    }

    // MARK: - Notification delegate

    func test_didReceive_should_openDeepLinkFromNotification() async {
        // Arrange
        let sut = makeSUT()
        let response = makeNotificationResponse(userInfo: ["url": "hidayahapp://inAppDeeplink/tracker"])
        var completed = false

        // Act
        sut.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response,
            withCompletionHandler: { completed = true }
        )

        // Assert
        XCTAssertTrue(completed)
        await waitUntil { sut.router.selectedTab == .tracker }
    }

    func test_didReceive_should_openSurahFromKahfReminder() async {
        // Arrange
        let sut = makeSUT()
        let response = makeNotificationResponse(userInfo: ["url": "hidayahapp://inAppDeeplink/quran/18"])

        // Act
        sut.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response,
            withCompletionHandler: {}
        )

        // Assert
        await waitUntil { !sut.router.quranPath.isEmpty }
        XCTAssertEqual(
            sut.router.quranPath,
            [.surahDetail(surahNumber: 18, title: nil, bookmarkedAyah: nil)]
        )
    }

    func test_didReceive_should_onlyCompleteWhenNotificationHasNoURL() async throws {
        // Arrange
        let sut = makeSUT()
        sut.router.selectTab(.search)
        let response = makeNotificationResponse(userInfo: [:])
        var completed = false

        // Act
        sut.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response,
            withCompletionHandler: { completed = true }
        )
        try await Task.sleep(for: .milliseconds(50))

        // Assert
        XCTAssertTrue(completed)
        XCTAssertEqual(sut.router.selectedTab, .search)
    }

    func test_willPresent_should_showBannerListAndSound() {
        // Arrange
        let sut = makeSUT()
        let notification = makeNotification(userInfo: [:])
        var options: UNNotificationPresentationOptions?

        // Act
        sut.userNotificationCenter(
            UNUserNotificationCenter.current(),
            willPresent: notification,
            withCompletionHandler: { options = $0 }
        )

        // Assert
        XCTAssertEqual(options, [.list, .banner, .sound])
    }

    // MARK: - Remote notifications

    func test_remoteNotificationCallbacks_should_completeWithoutSideEffects() {
        // Arrange
        let sut = makeSUT()
        let application = UIApplication.shared
        let before = center.scheduled.count

        // Act
        sut.application(application, didRegisterForRemoteNotificationsWithDeviceToken: Data([0x0a, 0xff]))
        sut.application(application, didFailToRegisterForRemoteNotificationsWithError: CoreTestError.unavailable)
        sut.application(application, didReceiveRemoteNotification: [:], fetchCompletionHandler: { _ in })

        // Assert
        XCTAssertEqual(center.scheduled.count, before)
        XCTAssertNil(sut.router.errorMessage)
    }
}
