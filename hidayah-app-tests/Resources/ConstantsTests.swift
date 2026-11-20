//
//  ConstantsTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

final class ConstantsTests: XCTestCase {
    func test_constants_should_exposeContactLinks() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let urls = [Constants.websiteUrl, Constants.privacyUrl, Constants.termConditionUrl]

        // Assert
        XCTAssertEqual(Constants.feedbackEmail, "mohammadhasifafiq@gmail.com")
        XCTAssertTrue(urls.allSatisfy { URL(string: $0)?.scheme == "https" })
    }

    func test_getLanguageFromCode_should_returnLocalisedLanguageName() {
        // Arrange
        let code = "EN"

        // Act
        let name = Constants.getLanguageFromCode(code: code)

        // Assert
        XCTAssertEqual(name, Locale.current.localizedString(forLanguageCode: "en"))
        XCTAssertNotEqual(name, "Unknown")
    }

    func test_getLanguageFromCode_should_returnUnknownForEmptyCode() {
        // Arrange
        let code = ""

        // Act
        let name = Constants.getLanguageFromCode(code: code)

        // Assert
        XCTAssertEqual(name, "Unknown")
    }

    func test_getLanguageFromCode_should_returnUnknownForUnrecognisedCode() {
        // Arrange
        let code = "zz-not-a-language-1234"

        // Act
        let name = Constants.getLanguageFromCode(code: code)

        // Assert
        XCTAssertEqual(name, Locale.current.localizedString(forLanguageCode: code) ?? "Unknown")
    }
}
