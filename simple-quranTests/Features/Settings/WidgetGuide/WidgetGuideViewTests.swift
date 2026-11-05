//
//  WidgetGuideViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class WidgetGuideViewTests: ViewsTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
    }

    func test_widgetGuideView_should_showTrackerPreviewByDefault() {
        // Arrange
        let taskManager = ViewsFixtures.makeTaskManager()
        let firstTask = taskManager.tasks.first?.name ?? ""

        // Act
        let host = sceneHost(
            NavigationStack { WidgetGuideView(taskManager: taskManager) }
        )
        host.pump(0.3)

        // Assert
        XCTAssertFalse(firstTask.isEmpty)
        XCTAssertTrue(host.contains("Choose a widget"))
        XCTAssertTrue(host.contains("Live Preview"))
        XCTAssertTrue(host.contains("Upcoming"))
        XCTAssertTrue(host.contains("0%"))
        XCTAssertTrue(host.contains("0/\(taskManager.tasks.count)"))
        XCTAssertTrue(host.contains(firstTask))
        XCTAssertTrue(host.contains("Track daily progress and upcoming tasks."))
        XCTAssertTrue(host.contains("How to Add a Widget"))
        XCTAssertTrue(host.contains("Touch and hold an empty area of the Home Screen."))
        XCTAssertTrue(host.contains("Choose the widget size, then tap Add Widget."))
        XCTAssertTrue(host.contains("Widgets update automatically"))
        XCTAssertFalse(host.contains("Customize Quick Surahs"))
    }

    func test_widgetGuideView_should_showQuickSurahsWhenSelected() {
        // Arrange
        let taskManager = ViewsFixtures.makeTaskManager()
        let host = sceneHost(
            NavigationStack { WidgetGuideView(taskManager: taskManager) }
        )

        // Act
        host.tap("Quick Surahs")
        host.pump(0.4)

        // Assert
        XCTAssertTrue(host.contains("Open your chosen surahs instantly."))
        XCTAssertTrue(host.contains("Customize Quick Surahs"))
        XCTAssertTrue(host.contains("Touch and hold the Quick Surahs widget."))
        XCTAssertTrue(host.contains("Tap Edit Widget."))
        XCTAssertTrue(host.contains("Select Surahs, search for a surah"))
        XCTAssertTrue(host.contains("Al-Kahf"))
        XCTAssertTrue(host.contains("Yaseen"))
        XCTAssertFalse(host.contains("Upcoming"))
    }

    func test_widgetGuideView_should_returnToTrackerPreview() {
        // Arrange
        let host = sceneHost(
            NavigationStack {
                WidgetGuideView(taskManager: ViewsFixtures.makeTaskManager())
            }
        )
        host.tap("Quick Surahs")

        // Act
        host.tap("Istiqamah Tracker")
        host.pump(0.4)

        // Assert
        XCTAssertTrue(host.contains("Upcoming"))
        XCTAssertFalse(host.contains("Customize Quick Surahs"))
    }

    func test_widgetGuidePreviewView_should_showProgressAndUpcomingTasks() {
        // Arrange
        let tasks = [
            TaskDetails(name: "Read Al-Mulk", category: .default(.bedtime)),
            TaskDetails(name: "Morning dhikr", category: .default(.morning))
        ]

        // Act
        let host = sceneHost(
            WidgetGuidePreviewView(
                kind: .tracker,
                progress: 0.5,
                completedCount: 2,
                totalCount: 4,
                upcomingTasks: tasks,
                quickSurahs: []
            )
        )

        // Assert
        XCTAssertTrue(host.contains("50%"))
        XCTAssertTrue(host.contains("2/4"))
        XCTAssertTrue(host.contains("Read Al-Mulk"))
        XCTAssertTrue(host.contains("Morning dhikr"))
        XCTAssertTrue(host.contains("9:41"))
        XCTAssertTrue(host.contains("Messages"))
        XCTAssertTrue(host.contains("Safari"))
        XCTAssertTrue(host.contains("Camera"))
        XCTAssertTrue(host.contains("Music"))
        XCTAssertFalse(host.contains("No upcoming tasks"))
    }

    func test_widgetGuidePreviewView_should_showNoUpcomingMessageWhenAllDone() {
        // Arrange
        let preview = WidgetGuidePreviewView(
            kind: .tracker,
            progress: 1,
            completedCount: 3,
            totalCount: 3,
            upcomingTasks: [],
            quickSurahs: []
        )

        // Act
        let host = sceneHost(preview)

        // Assert
        XCTAssertTrue(host.contains("100%"))
        XCTAssertTrue(host.contains("No upcoming tasks"))
    }

    func test_widgetGuidePreviewView_should_showQuickSurahCards() {
        // Arrange
        let surahs = [
            WidgetGuideSurah(number: 67, name: "Al-Mulk", arabic: "الملك")
        ]

        // Act
        let host = sceneHost(
            WidgetGuidePreviewView(
                kind: .quickSurahs,
                progress: 0,
                completedCount: 0,
                totalCount: 0,
                upcomingTasks: [],
                quickSurahs: surahs
            )
        )

        // Assert
        XCTAssertTrue(host.contains("Quick Access"))
        XCTAssertTrue(host.contains("67"))
        XCTAssertTrue(host.contains("الملك"))
        XCTAssertTrue(host.contains("Al-Mulk"))
        XCTAssertFalse(host.contains("Upcoming"))
    }
}
