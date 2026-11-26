//
//  RakaatPrayerTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class RakaatPrayerTests: XCTestCase {
    func test_presets_should_haveFardRakaatCounts() {
        // Arrange
        let prayers: [RakaatPrayer] = [.fajr, .dhuhr, .asr, .maghrib, .isha, .sunnah, .witir]

        // Act
        let counts = prayers.map(\.rakaatCount)

        // Assert
        XCTAssertEqual(counts, [2, 4, 4, 3, 4, 2, 3])
        XCTAssertEqual(RakaatPrayer.presets, prayers)
    }

    func test_tashahhudRakaat_should_includeSecond_when_prayerHasThreeOrMore() {
        // Arrange
        let prayers: [RakaatPrayer] = [.fajr, .maghrib, .isha, .custom(rakaat: 1)]

        // Act
        let positions = prayers.map(\.tashahhudRakaat)

        // Assert
        XCTAssertEqual(positions, [[2], [2, 3], [2, 4], [1]])
    }

    func test_custom_should_clampToRange() {
        // Arrange
        let tooFew = RakaatPrayer.custom(rakaat: 0)
        let tooMany = RakaatPrayer.custom(rakaat: 40)

        // Act
        let counts = (tooFew.rakaatCount, tooMany.rakaatCount)

        // Assert
        XCTAssertEqual(counts.0, 1)
        XCTAssertEqual(counts.1, 12)
    }

    func test_prayers_should_haveLocalizedNames() {
        // Arrange
        let prayers = RakaatPrayer.presets + [.custom(rakaat: 2)]

        // Act
        let missing = prayers.filter { $0.displayName.hasPrefix("rakaat_") }

        // Assert
        XCTAssertEqual(missing, [])
        XCTAssertEqual(RakaatPrayer.fajr.displayName, "Fajr")
    }

    func test_prayer_should_roundTripThroughCodable() throws {
        // Arrange
        let prayers: [RakaatPrayer] = [.maghrib, .custom(rakaat: 6)]

        // Act
        let data = try JSONEncoder().encode(prayers)
        let decoded = try JSONDecoder().decode([RakaatPrayer].self, from: data)

        // Assert
        XCTAssertEqual(decoded, prayers)
    }
}
