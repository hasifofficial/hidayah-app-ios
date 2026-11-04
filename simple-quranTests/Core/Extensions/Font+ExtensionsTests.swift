//
//  Font+ExtensionsTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class FontExtensionsTests: XCTestCase {
    func test_customFonts_should_buildNamedFonts() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let fonts = [
            Font.amiriBold(size: 20),
            Font.amiriRegular(size: 20),
            Font.kitabRegular(size: 20),
            Font.kitabBold(size: 20)
        ]

        // Assert
        XCTAssertEqual(fonts, [
            .custom("Amiri-Bold", size: 20),
            .custom("Amiri-Regular", size: 20),
            .custom("Kitab-Regular", size: 20),
            .custom("Kitab-Bold", size: 20)
        ])
    }

    func test_surahNameFont_should_useSurahNameTypeface() {
        // Arrange
        let size: CGFloat = 50

        // Act
        let font = Font.surahNameFont(size: size)

        // Assert
        XCTAssertEqual(font, .custom("surah-name-v2", size: 50))
    }

    func test_surahNameLigature_should_padNumberToThreeDigits() {
        // Arrange
        let numbers = [1, 18, 114]

        // Act
        let ligatures = numbers.map(Font.surahNameLigature(for:))

        // Assert
        XCTAssertEqual(ligatures, ["surah001", "surah018", "surah114"])
    }

    func test_surahNameLigature_should_returnNil_when_numberIsOutOfRange() {
        // Arrange
        let numbers = [0, 115, -1]

        // Act
        let ligatures = numbers.map(Font.surahNameLigature(for:))

        // Assert
        XCTAssertEqual(ligatures, [nil, nil, nil])
    }

    func test_loadFontsBundle_should_registerSurahNameFont() {
        // Arrange
        let bundle = "Fonts"

        // Act
        Font.loadFontsBundle(bundle: bundle, fontExtension: "ttf")

        // Assert
        XCTAssertNotNil(UIFont(name: "surah-name-v2", size: 20))
    }

    func test_loadFontsBundle_should_ignoreMissingBundle() {
        // Arrange
        let bundle = "DoesNotExist"

        // Act
        Font.loadFontsBundle(bundle: bundle, fontExtension: "ttf")

        // Assert
        XCTAssertNil(Bundle.main.url(forResource: bundle, withExtension: "bundle"))
    }
}
