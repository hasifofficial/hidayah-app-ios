//
//  SurahBookmarkTests.swift
//  hidayah-app-tests
//

import SwiftUI
import XCTest
@testable import hidayah_app

final class SurahBookmarkTests: XCTestCase {
    func test_surahBookmark_should_compareByLocation() {
        // Arrange
        let bookmark = SurahBookmark(surahNumber: 18, numberInSurah: 10)

        // Act
        let same = SurahBookmark(surahNumber: 18, numberInSurah: 10)

        // Assert
        XCTAssertEqual(bookmark, same)
        XCTAssertNotEqual(bookmark, SurahBookmark(surahNumber: 18, numberInSurah: 11))
    }
}
