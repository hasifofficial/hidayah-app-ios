//
//  NotificationIdentifierTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class NotificationIdentifierTests: XCTestCase {
    func test_notificationIdentifier_should_useAppPrefixedIdentifiers() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let kahf = NotificationIdentifier.kahfReminder.rawValue
        let cheer = NotificationIdentifier.trackerDailyCheer.rawValue

        // Assert
        XCTAssertEqual(kahf, "com.hasifofficial.simple-quran.kahf-reminder-notification")
        XCTAssertEqual(cheer, "com.hasifofficial.simple-quran.tracker-daily-cheer")
        XCTAssertFalse(cheer.hasPrefix(NotificationIdentifier.trackerMilestonePrefix))
    }
}
