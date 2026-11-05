//
//  QuickSurahWidgetTests.swift
//  app-widgetTests
//

import SwiftUI
import WidgetKit
import XCTest

@MainActor
final class QuickSurahWidgetTests: XCTestCase {
    private let size = CGSize(width: 400, height: 400)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    /// The `kind` WidgetKit receives from a widget's configuration.
    private func configuredKind(_ configuration: Any) -> String? {
        firstLabelled("kind", in: configuration) as? String
    }

    private func firstLabelled(_ label: String, in value: Any, depth: Int = 0) -> Any? {
        guard depth < 12 else { return nil }
        for child in Mirror(reflecting: value).children {
            if child.label == label {
                return child.value
            }
            if let match = firstLabelled(label, in: child.value, depth: depth + 1) {
                return match
            }
        }
        return nil
    }

    func test_quickSurahWidget_should_configureQuickSurahKind() {
        // Arrange
        let widget = QuickSurahWidget()

        // Act
        let kind = configuredKind(widget.body)

        // Assert
        XCTAssertEqual(widget.kind, "QuickSurahWidget")
        XCTAssertEqual(kind, "QuickSurahWidget")
    }

    func test_quickSurahWidget_should_buildEntryViewForEntry() {
        // Arrange
        let entry = QuickSurahProvider.placeholderEntry(date: Date())

        // Act
        let view = QuickSurahWidget.entryView(for: entry)
        let host = ViewHost(view, size: size)

        // Assert
        XCTAssertEqual(view.entry.surahs, QuickSurahCatalog.quickAccess)
        XCTAssertTrue(host.contains("Yaseen"), "\(host.labels())")
    }

    func test_surahNameLigature_should_matchTheAppsFormat() {
        // Arrange
        let numbers = [1, 18, 114, 0, 115]

        // Act
        let ligatures = numbers.map(QuickSurahWidgetEntryView.surahNameLigature(for:))

        // Assert
        XCTAssertEqual(ligatures, ["surah001", "surah018", "surah114", nil, nil])
    }

    func test_entryView_should_labelCalligraphyWithArabicName() {
        // Arrange
        let entry = QuickSurahProvider.placeholderEntry(date: Date())
        let firstName = entry.surahs[0].arabicName

        // Act
        let host = ViewHost(QuickSurahWidget.entryView(for: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(firstName), "\(host.labels())")
        XCTAssertFalse(host.contains("surah0"), "\(host.labels())")
    }
}
