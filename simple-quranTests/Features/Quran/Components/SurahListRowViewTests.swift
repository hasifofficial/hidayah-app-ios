//
//  SurahListRowViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class SurahListRowViewTests: ViewsTestCase {
    func test_surahListRow_should_readArabicName_when_drawnWithSurahNameFont() {
        // Arrange
        let row = SurahListRowView(
            title: "Al-Kahf",
            subtitle: "Makkiyah • 110 verses",
            arabicTitle: "سُورَةُ الكَهۡفِ",
            surahNumber: 18
        )

        // Act
        let host = sceneHost(row)

        // Assert
        XCTAssertTrue(host.contains("سُورَةُ الكَهۡفِ"))
        XCTAssertFalse(host.contains("surah018"))
    }

    func test_surahListRow_should_showArabicText_when_numberIsMissing() {
        // Arrange
        let row = SurahListRowView(
            title: "Dhikr",
            subtitle: "Subtitle",
            arabicTitle: "المأثورات"
        )

        // Act
        let host = sceneHost(row)

        // Assert
        XCTAssertTrue(host.contains("المأثورات"))
    }

    func test_surahListRow_should_showArabicText_when_numberIsOutOfRange() {
        // Arrange
        let row = SurahListRowView(
            title: "Unknown",
            subtitle: "Subtitle",
            arabicTitle: "سورة",
            surahNumber: 200
        )

        // Act
        let host = sceneHost(row)

        // Assert
        XCTAssertTrue(host.contains("سورة"))
        XCTAssertFalse(host.contains("surah200"))
    }
}
