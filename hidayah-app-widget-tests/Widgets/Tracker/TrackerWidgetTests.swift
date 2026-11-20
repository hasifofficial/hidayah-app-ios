//
//  TrackerWidgetTests.swift
//  app-widgetTests
//

import SwiftUI
import WidgetKit
import XCTest

@MainActor
final class TrackerWidgetTests: XCTestCase {
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

    func test_trackerWidget_should_configureTrackerKind() {
        // Arrange
        let widget = TrackerWidget()

        // Act
        let kind = configuredKind(widget.body)

        // Assert
        XCTAssertEqual(widget.kind, "TrackerWidget")
        XCTAssertEqual(kind, "TrackerWidget")
    }

    func test_trackerWidget_should_buildEntryViewForEntry() {
        // Arrange
        let entry = makeEntry(progress: 0.4, completed: 2, total: 5)

        // Act
        let view = TrackerWidget.entryView(for: entry)
        let host = ViewHost(view, size: size)

        // Assert
        XCTAssertEqual(view.entry.completedTasks, 2)
        XCTAssertTrue(host.contains("40%"), "\(host.labels())")
    }
}
