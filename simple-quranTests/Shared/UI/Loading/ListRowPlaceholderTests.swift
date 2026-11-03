//
//  ListRowPlaceholderTests.swift
//  simple-quranTests
//

import MessageUI
import SafariServices
import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class ListRowPlaceholderTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_loadingPlaceholders_should_renderShimmerBars() {
        // Arrange
        let view = VStack {
            ListRowPlaceholder()
            ShimmerBar().frame(width: 120, height: 12)
            Text("Animated").loadAnimation(delay: 0.1, offset: 20)
        }

        // Act
        let host = sceneHost(view, size: CGSize(width: 402, height: 400))
        host.pump(0.6)

        // Assert
        XCTAssertTrue(host.contains("Animated"))
    }
}
