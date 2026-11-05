//
//  QuickSurahProviderTests.swift
//  app-widgetTests
//

import AppIntents
import WidgetKit
import XCTest

@MainActor
final class QuickSurahProviderTests: XCTestCase {
    private let date = trackerDate(year: 2026, month: 11, day: 3)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func configuration(_ numbers: [Int]?) -> QuickSurahConfigurationIntent {
        var intent = QuickSurahConfigurationIntent()
        intent.surahs = numbers.map { numbers in
            numbers.map { QuickSurahCatalog.all[$0 - 1] }
        }
        return intent
    }

    func test_selectedSurahs_should_fallBackToQuickAccess_when_nothingIsSelected() {
        // Arrange
        let intent = configuration(nil)

        // Act
        let surahs = QuickSurahProvider.selectedSurahs(from: intent)

        // Assert
        XCTAssertEqual(surahs, QuickSurahCatalog.quickAccess)
    }

    func test_selectedSurahs_should_fallBackToQuickAccess_when_selectionIsEmpty() {
        // Arrange
        let intent = configuration([])

        // Act
        let surahs = QuickSurahProvider.selectedSurahs(from: intent)

        // Assert
        XCTAssertEqual(surahs, QuickSurahCatalog.quickAccess)
    }

    func test_selectedSurahs_should_keepFirstThreeSelected() {
        // Arrange
        let intent = configuration([1, 2, 3, 4])

        // Act
        let surahs = QuickSurahProvider.selectedSurahs(from: intent)

        // Assert
        XCTAssertEqual(surahs.map(\.number), [1, 2, 3])
    }

    func test_placeholderEntry_should_showQuickAccessSurahs() {
        // Arrange
        let expected = QuickSurahCatalog.quickAccess

        // Act
        let entry = QuickSurahProvider.placeholderEntry(date: date)

        // Assert
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.surahs, expected)
    }

    func test_entry_should_showSelectedSurahs() {
        // Arrange
        let intent = configuration([112])

        // Act
        let entry = QuickSurahProvider.entry(for: intent, date: date)

        // Assert
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.surahs.map(\.englishName), ["Al-Ikhlaas"])
    }

    func test_timeline_should_holdOneEntryAndNeverRefresh() {
        // Arrange
        let intent = configuration([18, 36])

        // Act
        let timeline = QuickSurahProvider.timeline(for: intent, date: date)

        // Assert
        XCTAssertEqual(timeline.entries.count, 1)
        XCTAssertEqual(timeline.entries.first?.surahs.map(\.number), [18, 36])
        XCTAssertEqual(timeline.policy, .never)
    }
}
