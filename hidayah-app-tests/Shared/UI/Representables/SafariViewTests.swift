//
//  SafariViewTests.swift
//  hidayah-app-tests
//

import MessageUI
import SafariServices
import SwiftUI
import XCTest
@testable import hidayah_app

@MainActor
final class SafariViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_safariView_should_hostSafariControllerForURL() {
        // Arrange
        let url = URL(string: "https://www.hasifofficial.com")!

        // Act
        let host = sceneHost(SafariView(url: url))
        host.pump(0.3)

        // Assert
        let safari = host.controller.children.first { $0 is SFSafariViewController }
        XCTAssertNotNil(safari)
    }
}
