//
//  HomeShortcutsTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class HomeShortcutsTests: XCTestCase {
    func test_decode_should_returnDefaults_when_nothingIsStored() {
        // Arrange
        let stored: [String?] = [nil, "", "unknown,,"]

        // Act
        let decoded = stored.map(HomeShortcuts.decode)

        // Assert
        for features in decoded {
            XCTAssertEqual(features, [.quran, .mathurat, .tasbih])
        }
    }

    func test_decode_should_keepOrderAndDropUnknownOrRepeatedFeatures() {
        // Arrange
        let raw = "tracker,gone,quran,tracker"

        // Act
        let features = HomeShortcuts.decode(raw)

        // Assert
        XCTAssertEqual(features, [.tracker, .quran])
    }

    func test_decode_should_capAtLimit() {
        // Arrange
        let raw = "tracker,tasbih,mathurat,quran"

        // Act
        let features = HomeShortcuts.decode(raw)

        // Assert
        XCTAssertEqual(features, [.tracker, .tasbih, .mathurat])
    }

    func test_saveAndLoad_should_roundTrip() throws {
        // Arrange
        let store = try XCTUnwrap(UserDefaults(suiteName: "HomeShortcutsTests.\(UUID())"))

        // Act
        HomeShortcuts.save([.tasbih, .tracker], to: store)
        let loaded = HomeShortcuts.load(from: store)

        // Assert
        XCTAssertEqual(loaded, [.tasbih, .tracker])
        XCTAssertEqual(store.string(forKey: "homeShortcuts"), "tasbih,tracker")
    }
}
