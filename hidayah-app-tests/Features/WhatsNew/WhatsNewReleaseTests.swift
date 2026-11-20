//
//  WhatsNewReleaseTests.swift
//  simple-quranTests
//

import UIKit
import XCTest
@testable import simple_quran

final class WhatsNewReleaseTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_isUnseen_should_beTrue_when_nothingWasSeen() {
        // Arrange
        let release = WhatsNewRelease.current

        // Act
        let isUnseen = release.isUnseen

        // Assert
        XCTAssertTrue(isUnseen)
    }

    func test_markSeen_should_hideTheSameRelease() {
        // Arrange
        let release = WhatsNewRelease.current

        // Act
        release.markSeen()

        // Assert
        XCTAssertFalse(release.isUnseen)
        XCTAssertEqual(
            Storage.load(key: .whatsNewLastSeenVersion) as? String,
            release.version
        )
    }

    func test_isUnseen_should_beTrue_when_aNewerReleaseShips() {
        // Arrange
        WhatsNewRelease(version: "1.0", features: []).markSeen()

        // Act
        let isUnseen = WhatsNewRelease(version: "2.0", features: []).isUnseen

        // Assert
        XCTAssertTrue(isUnseen)
    }

    func test_current_should_haveAnIllustrationAndTextForEveryFeature() {
        // Arrange
        let features = WhatsNewRelease.current.features

        // Act
        let missing = features.filter { feature in
            UIImage(named: feature.illustration) == nil
                || NSLocalizedString(feature.titleKey, comment: "") == feature.titleKey
                || NSLocalizedString(feature.bodyKey, comment: "") == feature.bodyKey
        }

        // Assert
        XCTAssertFalse(features.isEmpty)
        XCTAssertEqual(missing.map(\.id), [])
    }
}
