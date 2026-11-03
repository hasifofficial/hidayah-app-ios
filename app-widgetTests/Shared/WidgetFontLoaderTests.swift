//
//  WidgetFontLoaderTests.swift
//  app-widgetTests
//

import CoreText
import UIKit
import XCTest

@MainActor
final class WidgetFontLoaderTests: XCTestCase {
    private var testBundle: Bundle { Bundle(for: Self.self) }

    /// The folder the widget ships its fonts in.
    private var fontsBundle: Bundle {
        get throws {
            let url = try XCTUnwrap(
                testBundle.url(forResource: "Fonts", withExtension: "bundle")
            )
            return try XCTUnwrap(Bundle(url: url))
        }
    }

    override func setUp() {
        super.setUp()
        resetStorage()
        unregisterFonts()
        WidgetFontLoader.isRegistered = false
    }

    override func tearDown() {
        unregisterFonts()
        WidgetFontLoader.isRegistered = false
        super.tearDown()
    }

    private func unregisterFonts() {
        guard let bundle = try? fontsBundle else { return }
        for url in WidgetFontLoader.fontURLs(in: bundle) {
            CTFontManagerUnregisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    private func isRegistered(_ url: URL) -> Bool {
        var error: Unmanaged<CFError>?
        let registeredNow = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        if registeredNow {
            CTFontManagerUnregisterFontsForURL(url as CFURL, .process, nil)
            return false
        }
        let code = error.map { CFErrorGetCode($0.takeRetainedValue()) }
        return code == CTFontManagerError.alreadyRegistered.rawValue
    }

    func test_fontURLs_should_findBothKitabFonts_inFontsBundle() throws {
        // Arrange
        let bundle = try fontsBundle

        // Act
        let urls = WidgetFontLoader.fontURLs(in: bundle)

        // Assert
        XCTAssertEqual(
            urls.map(\.lastPathComponent).sorted(),
            ["Kitab-Bold.ttf", "Kitab-Regular.ttf"]
        )
    }

    func test_fontURLs_should_findNothing_when_fontsSitInSubfolder() {
        // Arrange
        // The widget's resources nest the fonts in Fonts.bundle, like the
        // test bundle does, so a top-level lookup finds none of them.
        let bundle = testBundle

        // Act
        let urls = WidgetFontLoader.fontURLs(in: bundle)

        // Assert
        XCTAssertTrue(urls.isEmpty, "\(urls)")
    }

    func test_registerFonts_should_registerEveryFont() throws {
        // Arrange
        let bundle = try fontsBundle

        // Act
        WidgetFontLoader.registerFonts(in: bundle)

        // Assert
        XCTAssertTrue(WidgetFontLoader.isRegistered)
        for url in WidgetFontLoader.fontURLs(in: bundle) {
            XCTAssertTrue(isRegistered(url), url.lastPathComponent)
        }
        XCTAssertNotNil(UIFont(name: "Kitab-Regular", size: 12))
    }

    func test_registerFonts_should_doNothing_when_alreadyRegistered() throws {
        // Arrange
        let bundle = try fontsBundle
        WidgetFontLoader.registerFonts(in: testBundle)

        // Act
        WidgetFontLoader.registerFonts(in: bundle)

        // Assert
        XCTAssertTrue(WidgetFontLoader.isRegistered)
        for url in WidgetFontLoader.fontURLs(in: bundle) {
            XCTAssertFalse(isRegistered(url), url.lastPathComponent)
        }
    }

    func test_registerFonts_should_useMainBundle_byDefault() {
        // Arrange
        XCTAssertFalse(WidgetFontLoader.isRegistered)

        // Act
        WidgetFontLoader.registerFonts()

        // Assert
        XCTAssertTrue(WidgetFontLoader.isRegistered)
    }
}
