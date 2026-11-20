//
//  SurahBookmarkTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

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
