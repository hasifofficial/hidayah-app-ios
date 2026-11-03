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

    func test_loadFontsBundle_should_ignoreMissingBundle() {
        // Arrange
        let bundle = "DoesNotExist"

        // Act
        Font.loadFontsBundle(bundle: bundle, fontExtension: "ttf")

        // Assert
        XCTAssertNil(Bundle.main.url(forResource: bundle, withExtension: "bundle"))
    }
}
