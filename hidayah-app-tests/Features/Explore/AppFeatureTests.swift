//
//  AppFeatureTests.swift
//  hidayah-app-tests
//

import UIKit
import XCTest
@testable import hidayah_app

@MainActor
final class AppFeatureTests: XCTestCase {
    func test_allCases_should_listMainFeaturesInOrder() {
        // Arrange
        let expected: [AppFeature] = [.quran, .mathurat, .tasbih, .qibla, .tracker]

        // Act
        let features = AppFeature.allCases

        // Assert
        XCTAssertEqual(features, expected)
        XCTAssertEqual(AppFeature.tracker.title, "Istiqamah Tracker")
    }

    func test_features_should_haveLocalizedText() {
        // Arrange
        let features = AppFeature.allCases

        // Act
        let missing = features.filter {
            $0.title.isEmpty
                || $0.subtitle.hasPrefix("explore_")
                || $0.title.hasPrefix("explore_")
        }

        // Assert
        XCTAssertEqual(missing, [])
    }

    func test_tasbih_should_useBeadIcon() {
        // Arrange
        let feature = AppFeature.tasbih

        // Act
        let assetIcon = feature.assetIcon

        // Assert
        XCTAssertEqual(assetIcon, "TasbihIconFill")
        XCTAssertNil(AppFeature.quran.assetIcon)
    }

    func test_illustrations_should_existInAssetCatalog() {
        // Arrange
        let names = AppFeature.allCases.map(\.illustration)
            + MathuratTime.allCases.map(\.illustration)
            + [
                AppFeature.allIllustration,
                Illustration.quranClosed,
                Illustration.bookmark,
                Illustration.mathuratEvening
            ]

        // Act
        let missing = names.filter { UIImage(named: $0) == nil }

        // Assert
        XCTAssertEqual(missing, [])
        XCTAssertEqual(AppFeature.mathurat.illustration, "IllustrationMathurat")
    }

    func test_open_should_pushRouteFeatureOnCurrentStack() {
        // Arrange
        let router = AppRouter()
        router.homePath = [.explore]

        // Act
        router.open(.quran)

        // Assert
        XCTAssertEqual(router.selectedTab, .home)
        XCTAssertEqual(router.homePath, [.explore, .quranList])
    }

    func test_open_should_switchTab_when_featureIsATab() {
        // Arrange
        let router = AppRouter()
        router.homePath = [.explore]

        // Act
        router.open(.tracker)

        // Assert
        XCTAssertEqual(router.selectedTab, .tracker)
        XCTAssertEqual(router.savedHomePath, [.explore])
    }

    func test_open_should_pushQibla() {
        // Arrange
        let router = AppRouter()
        router.homePath = [.explore]

        // Act
        router.open(.qibla)

        // Assert
        XCTAssertEqual(router.homePath, [.explore, .qibla])
        XCTAssertEqual(AppFeature.qibla.title, "Qibla")
    }
}
