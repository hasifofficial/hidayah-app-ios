//
//  MailViewTests.swift
//  simple-quranTests
//

import MessageUI
import SafariServices
import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class MailViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_mailView_should_makeCoordinatorForFinishCallback() {
        // Arrange
        var finished = 0
        let mailView = MailView(
            subject: "Feedback",
            recipients: ["feedback@example.com"],
            onFinish: { finished += 1 }
        )

        // Act
        let coordinator = mailView.makeCoordinator()

        // Assert
        // MFMailComposeViewController cannot be created on a simulator
        // without a mail account (it crashes), so the composer itself and
        // the delegate callback are not exercised here.
        XCTAssertTrue(coordinator.conforms(to: MFMailComposeViewControllerDelegate.self))
        XCTAssertEqual(mailView.subject, "Feedback")
        XCTAssertEqual(mailView.recipients, ["feedback@example.com"])
        XCTAssertEqual(finished, 0)
    }
}
