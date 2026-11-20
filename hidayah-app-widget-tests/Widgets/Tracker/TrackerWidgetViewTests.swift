//
//  TrackerWidgetViewTests.swift
//  app-widgetTests
//

import SwiftUI
import WidgetKit
import XCTest

@MainActor
final class TrackerWidgetViewTests: XCTestCase {
    private let size = CGSize(width: 400, height: 400)

    override func setUp() {
        super.setUp()
        resetStorage()
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    func test_smallView_should_showPercentAndTaskCount() {
        // Arrange
        let entry = makeEntry(progress: 0.65, completed: 15, total: 23)

        // Act
        let host = ViewHost(TrackerWidgetSmallView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains("65%"), "\(host.labels())")
        let count = String(format: localized("widget_tasks_count_format"), 15, 23)
        XCTAssertTrue(host.contains(count), "\(host.labels())")
    }

    func test_smallView_should_capPercentAtHundred_when_progressExceedsOne() {
        // Arrange
        let entry = makeEntry(progress: 1.4, completed: 3, total: 3)

        // Act
        let host = ViewHost(TrackerWidgetSmallView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains("100%"), "\(host.labels())")
    }

    func test_smallView_should_showZeroPercent_when_progressIsNegative() {
        // Arrange
        let entry = makeEntry(progress: -0.3, completed: 0, total: 3)

        // Act
        let host = ViewHost(TrackerWidgetSmallView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains("0%"), "\(host.labels())")
        XCTAssertFalse(host.contains("-"), "\(host.labels())")
    }

    func test_mediumView_should_listAtMostFiveUpcomingTasks() {
        // Arrange
        let tasks = (1...7).map { makeTask("Task \($0)") }
        let entry = makeEntry(progress: 0.25, completed: 2, total: 9, upcoming: tasks)

        // Act
        let host = ViewHost(TrackerWidgetMediumView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(localized("widget_upcoming_title")), "\(host.labels())")
        XCTAssertTrue(host.contains("25%"), "\(host.labels())")
        XCTAssertTrue(host.contains("2/9"), "\(host.labels())")
        for index in 1...5 {
            XCTAssertTrue(host.contains("Task \(index)"), "Task \(index) missing: \(host.labels())")
        }
        XCTAssertFalse(host.contains("Task 6"))
        XCTAssertFalse(host.contains("Task 7"))
    }

    func test_mediumView_should_showCompletionMessage_when_allTasksAreDone() {
        // Arrange
        let entry = makeEntry(progress: 1, completed: 4, total: 4)
        let view = TrackerWidgetMediumView(entry: entry)

        // Act
        let host = ViewHost(view, size: size)

        // Assert
        XCTAssertTrue(host.contains(localized("widget_complete_title")), "\(host.labels())")
        XCTAssertTrue(host.contains(view.completionMessage), "\(host.labels())")
        XCTAssertTrue(host.contains("100%"), "\(host.labels())")
    }

    func test_mediumView_should_showRemainingCount_when_noUpcomingTasksButSomeAreLeft() {
        // Arrange
        let entry = makeEntry(progress: 0.5, completed: 2, total: 5)

        // Act
        let host = ViewHost(TrackerWidgetMediumView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(localized("widget_no_upcoming_title")), "\(host.labels())")
        let remaining = String(format: localized("widget_remaining_format"), 3)
        XCTAssertTrue(host.contains(remaining), "\(host.labels())")
        XCTAssertFalse(host.contains(localized("widget_complete_title")))
    }

    func test_mediumView_should_promptToAddTasks_when_thereAreNoTasks() {
        // Arrange
        let entry = makeEntry(progress: 0, completed: 0, total: 0)

        // Act
        let host = ViewHost(TrackerWidgetMediumView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains(localized("widget_no_tasks_title")), "\(host.labels())")
        XCTAssertTrue(host.contains(localized("widget_add_tasks_hint")), "\(host.labels())")
    }

    func test_completionMessage_should_rotateEveryFifteenMinutes() {
        // Arrange
        let start = Date(timeIntervalSince1970: 900 * 10)
        let views = (0..<5).map { offset in
            TrackerWidgetMediumView(
                entry: makeEntry(date: start.addingTimeInterval(Double(offset) * 900))
            )
        }

        // Act
        let messages = views.map(\.completionMessage)

        // Assert
        let expected = [1, 2, 3, 4, 5].map { localized("widget_completion_\($0)") }
        XCTAssertEqual(messages, expected)
    }

    func test_completionMessage_should_stayTheSame_withinFifteenMinutes() {
        // Arrange
        let start = Date(timeIntervalSince1970: 900 * 12)
        let early = TrackerWidgetMediumView(entry: makeEntry(date: start))
        let late = TrackerWidgetMediumView(entry: makeEntry(date: start.addingTimeInterval(899)))

        // Act
        let messages = [early.completionMessage, late.completionMessage]

        // Assert
        XCTAssertEqual(messages, [localized("widget_completion_3"), localized("widget_completion_3")])
    }

    func test_entryView_should_showMediumLayout_when_familyIsMedium() {
        // Arrange
        let entry = makeEntry(upcoming: [makeTask("Fajr prayer")])

        // Act
        let host = ViewHost(TrackerWidgetEntryView(entry: entry, family: .systemMedium), size: size)

        // Assert
        XCTAssertTrue(host.contains(localized("widget_upcoming_title")), "\(host.labels())")
        XCTAssertTrue(host.contains("Fajr prayer"), "\(host.labels())")
    }

    func test_entryView_should_showSmallLayout_when_familyIsSmall() {
        // Arrange
        let entry = makeEntry(upcoming: [makeTask("Fajr prayer")])

        // Act
        let host = ViewHost(TrackerWidgetEntryView(entry: entry, family: .systemSmall), size: size)

        // Assert
        XCTAssertTrue(host.contains("50%"), "\(host.labels())")
        XCTAssertFalse(host.contains("Fajr prayer"))
        XCTAssertFalse(host.contains(localized("widget_upcoming_title")))
    }

    func test_entryView_should_followEnvironmentFamily_when_noFamilyIsGiven() {
        // Arrange
        let entry = makeEntry(upcoming: [makeTask("Fajr prayer")])
        let isMedium = EnvironmentValues().widgetFamily == .systemMedium

        // Act
        let host = ViewHost(TrackerWidgetEntryView(entry: entry), size: size)

        // Assert
        XCTAssertTrue(host.contains("50%"), "\(host.labels())")
        XCTAssertEqual(host.contains("Fajr prayer"), isMedium, "\(host.labels())")
    }

    func test_widgetURL_should_openTrackerTab() {
        // Arrange
        let expected = "hidayahapp://inAppDeeplink/tracker"

        // Act
        let url = TrackerWidgetEntryView.widgetURL

        // Assert
        XCTAssertEqual(url?.absoluteString, expected)
    }

    func test_background_should_useStrongerTint_when_familyIsSmall() {
        // Arrange
        let background = TrackerWidgetBackground(family: .systemSmall)

        // Act
        let opacity = background.tintOpacity

        // Assert
        XCTAssertEqual(opacity, 0.26)
    }

    func test_background_should_useLighterTint_when_familyIsMedium() {
        // Arrange
        let background = TrackerWidgetBackground(family: .systemMedium)

        // Act
        let opacity = background.tintOpacity

        // Assert
        XCTAssertEqual(opacity, 0.18)
    }

    func test_background_should_render_forEachFamily() {
        // Arrange
        let families: [WidgetFamily?] = [.systemSmall, .systemMedium, nil]

        // Act
        let hosts = families.map { ViewHost(TrackerWidgetBackground(family: $0), size: size) }

        // Assert
        for host in hosts {
            XCTAssertEqual(host.controller.view.bounds.size, size)
            XCTAssertNotNil(host.controller.view.window)
        }
    }
}
