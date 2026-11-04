//
//  ReaderTextBlockTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class ReaderTextBlockTests: XCTestCase {
    private func runs(_ text: AttributedString) -> [(String, Font?)] {
        text.runs.map { (String(text[$0.range].characters), $0.font) }
    }

    func test_styledArabic_should_useNumberFontOnlyForDigits() {
        // Arrange
        let arabic = "ٱلْعَظِيمُ٢٥٥ وَلَا"

        // Act
        let styled = ReaderTextBlock.styledArabic(
            arabic,
            size: 22,
            numberFont: Font.uthmanicDouri(size:)
        )

        // Assert
        let parts = runs(styled)
        XCTAssertEqual(parts.map(\.0), ["ٱلْعَظِيمُ", "٢٥٥", " وَلَا"])
        XCTAssertEqual(parts.map(\.1), [
            .kitabRegular(size: 22),
            .uthmanicDouri(size: 22),
            .kitabRegular(size: 22)
        ])
    }

    func test_styledArabic_should_keepTextUnchanged() {
        // Arrange
        let arabic = "بِسْمِ ٱللَّهِ١ ٱلرَّحِيمِ٢"

        // Act
        let styled = ReaderTextBlock.styledArabic(
            arabic,
            size: 30,
            numberFont: Font.uthmanicDouri(size:)
        )

        // Assert
        XCTAssertEqual(String(styled.characters), arabic)
        XCTAssertEqual(runs(styled).filter { $0.1 == .uthmanicDouri(size: 30) }.map(\.0), ["١", "٢"])
    }

    func test_styledArabic_should_useKitabThroughout_when_textHasNoDigits() {
        // Arrange
        let arabic = "سُبْحَانَ ٱللَّهِ"

        // Act
        let styled = ReaderTextBlock.styledArabic(
            arabic,
            size: 22,
            numberFont: Font.uthmanicDouri(size:)
        )

        // Assert
        XCTAssertEqual(runs(styled).map(\.1), [.kitabRegular(size: 22)])
    }
}
