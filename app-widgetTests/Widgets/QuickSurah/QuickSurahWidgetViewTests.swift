//
//  QuickSurahWidgetViewTests.swift
//  app-widgetTests
//

import SwiftUI
import WidgetKit
import XCTest

@MainActor
final class QuickSurahWidgetViewTests: XCTestCase {
    private let size = CGSize(width: 400, height: 400)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_entryView_should_showHeaderAndQuickAccessCards() {
        // Arrange
        let entry = QuickSurahProvider.placeholderEntry(date: Date())

        // Act
        let host = ViewHost(QuickSurahWidgetEntryView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(NSLocalizedString("widget_quick_access_title", comment: "")), "\(host.labels())")
        XCTAssertTrue(host.contains("Al-Kahf"), "\(host.labels())")
        XCTAssertTrue(host.contains("As-Sajda"), "\(host.labels())")
        XCTAssertTrue(host.contains("Yaseen"), "\(host.labels())")
        XCTAssertFalse(host.contains("Al-Waaqia"), "only three cards fit: \(host.labels())")
        XCTAssertFalse(host.contains("Al-Mulk"))
    }

    func test_entryView_should_showArabicNameAndNumber_forEachSurah() {
        // Arrange
        let entry = QuickSurahEntry(
            date: Date(),
            surahs: [QuickSurahCatalog.all[111]]
        )

        // Act
        let host = ViewHost(QuickSurahWidgetEntryView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains("Al-Ikhlaas"), "\(host.labels())")
        XCTAssertTrue(host.contains("الإخلاص"), "\(host.labels())")
        XCTAssertTrue(host.contains("112"), "\(host.labels())")
    }

    func test_entryView_should_showNoCards_when_entryHasNoSurahs() {
        // Arrange
        let entry = QuickSurahEntry(date: Date(), surahs: [])

        // Act
        let host = ViewHost(QuickSurahWidgetEntryView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(NSLocalizedString("widget_quick_access_title", comment: "")))
        XCTAssertFalse(host.contains("Al-Kahf"))
    }

    func test_entryView_should_registerFonts() {
        // Arrange
        WidgetFontLoader.isRegistered = false

        // Act
        _ = QuickSurahWidgetEntryView(entry: QuickSurahEntry(date: Date(), surahs: []))

        // Assert
        XCTAssertTrue(WidgetFontLoader.isRegistered)
    }

    func test_background_should_render() {
        // Arrange
        let view = QuickSurahWidgetBackground()

        // Act
        let host = ViewHost(view, size: size)

        // Assert
        XCTAssertEqual(host.controller.view.bounds.size, size)
    }
}

@MainActor
final class QuickSurahWidgetLinkTests: XCTestCase {
    private let date = trackerDate(year: 2026, month: 11, day: 3)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_deepLink_should_openSurahInApp() {
        // Arrange
        let surah = QuickSurahCatalog.all[17]

        // Act
        let url = QuickSurahWidgetEntryView.deepLink(for: surah)

        // Assert
        XCTAssertEqual(url.absoluteString, "hidayahapp://inAppDeeplink/quran/18")
    }

    func test_widgetURL_should_openQuranTab() {
        // Arrange
        let expected = "hidayahapp://inAppDeeplink/quran"

        // Act
        let url = QuickSurahWidgetEntryView.widgetURL

        // Assert
        XCTAssertEqual(url?.absoluteString, expected)
    }
}
