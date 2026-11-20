//
//  AppDelegateTests.swift
//  simple-quranTests
//

import UIKit
import UserNotifications
import XCTest
@testable import simple_quran

@MainActor
final class AppDelegateTests: XCTestCase {
    private var previousDelegate: UNUserNotificationCenterDelegate?

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        previousDelegate = UNUserNotificationCenter.current().delegate
    }

    override func tearDown() async throws {
        UNUserNotificationCenter.current().delegate = previousDelegate
        resetStorage()
        try await super.tearDown()
    }

    func test_init_should_createAppControllerWithSharedServices() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = AppDelegate()

        // Assert
        XCTAssertTrue(sut.appController.taskManager === TaskManager.shared)
        XCTAssertTrue(UNUserNotificationCenter.current().delegate === sut.appController)
    }

    func test_didFinishLaunching_should_returnTrue() {
        // Arrange
        let sut = AppDelegate()

        // Act
        let result = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        // Assert
        XCTAssertTrue(result)
    }

    func test_remoteNotificationCallbacks_should_forwardToAppController() {
        // Arrange
        let sut = AppDelegate()
        let application = UIApplication.shared
        var fetchResultDelivered = false

        // Act
        sut.application(application, didRegisterForRemoteNotificationsWithDeviceToken: Data([0x01]))
        sut.application(application, didFailToRegisterForRemoteNotificationsWithError: CoreTestError.unavailable)
        sut.application(
            application,
            didReceiveRemoteNotification: [:],
            fetchCompletionHandler: { _ in fetchResultDelivered = true }
        )

        // Assert
        XCTAssertFalse(fetchResultDelivered, "the app controller does not handle background pushes yet")
        XCTAssertNil(sut.appController.router.errorMessage)
    }
}
