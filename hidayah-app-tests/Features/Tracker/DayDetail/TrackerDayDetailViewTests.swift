//
//  TrackerDayDetailViewTests.swift
//  simple-quranTests
//

import SwiftUI
import XCTest
@testable import simple_quran

@MainActor
final class TrackerDayDetailViewTests: XCTestCase {
    func test_body_should_showEmptyStateForADayWithoutRecord() {
        // Arrange
        let (taskManager, _, _) = makeTrackerFixture()

        // Act
        let host = ViewHost(
            NavigationStack {
                TrackerDayDetailView(taskManager: taskManager, dayKey: "2026-10-05", record: nil)
            }
        )
        host.pump(0.5)

        // Assert
        XCTAssertTrue(host.contains("No activity"))
        XCTAssertTrue(host.contains("No tasks were completed on this day."))
        XCTAssertTrue(host.contains("0/0"))
        XCTAssertTrue(host.contains("Daily Progress"))
    }

    func test_body_should_showTasksOfTheRecordedDay() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record([2])
        let record = taskManager.record(for: "2026-10-01")

        // Act
        let host = ViewHost(
            NavigationStack {
                TrackerDayDetailView(taskManager: taskManager, dayKey: "2026-10-01", record: record)
            }
        )
        host.pump(0.5)

        // Assert
        XCTAssertNotNil(record)
        XCTAssertTrue(host.contains("66%"))
        XCTAssertTrue(host.contains("2/3"))
        XCTAssertTrue(host.contains("20"))
        XCTAssertTrue(host.contains("Fajr (Dawn Prayer)"))
        XCTAssertTrue(host.contains("2 of 3 completed"))
        XCTAssertTrue(host.contains("Recite Quran"))
        XCTAssertFalse(host.contains("Perfect day"))
        XCTAssertFalse(host.contains("No activity"))
    }

    func test_body_should_markAPerfectDay() {
        // Arrange
        let (taskManager, _, builder) = makeTrackerFixture()
        builder.record([3])
        let record = taskManager.record(for: "2026-10-01")

        // Act
        let host = ViewHost(
            NavigationStack {
                TrackerDayDetailView(taskManager: taskManager, dayKey: "2026-10-01", record: record)
            }
        )
        host.pump(0.5)

        // Assert
        XCTAssertTrue(host.contains("Perfect day"))
        XCTAssertTrue(host.contains("100%"))
        XCTAssertTrue(host.contains("80"))
    }
}
