//
//  HidayahStoreMigrationTests.swift
//  hidayah-app-tests
//

import SwiftData
import XCTest
@testable import hidayah_app

@MainActor
final class HidayahStoreMigrationTests: XCTestCase {
    private var directory: URL!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HidayahStoreMigrationTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        resetStorage()
        try await super.tearDown()
    }

    func test_makeContainer_should_keepV1DataWhenOpeningAV1Store() throws {
        // Arrange
        let url = directory.appendingPathComponent("Hidayah.store")
        let taskID = UUID()
        try writeV1Store(at: url, taskID: taskID)

        // Act
        let store = HidayahStore(makeContainer: {
            try HidayahStore.makeContainer(at: url)
        })

        // Assert
        XCTAssertTrue(store.isPersistent, String(describing: store.loadError))
        let tasks = store.loadTrackerData().tasks
        XCTAssertEqual(tasks.map(\.id), [taskID])
        XCTAssertEqual(tasks.map(\.name), ["Fajr prayer"])
        XCTAssertEqual(tasks.map(\.isCompleted), [true])
        XCTAssertEqual(store.loadHistorySummaries().map(\.dayKey), ["2026-11-01"])
        XCTAssertEqual(store.loadHistorySummaries().map(\.points), [40])
        XCTAssertEqual(store.bookmarks().map(\.surahNumber), [18])
    }

    func test_makeContainer_should_storeQadaRowsAfterMigratingAV1Store() throws {
        // Arrange
        let url = directory.appendingPathComponent("Hidayah.store")
        try writeV1Store(at: url, taskID: UUID())
        let store = HidayahStore(makeContainer: {
            try HidayahStore.makeContainer(at: url)
        })

        // Act
        store.saveQadaYear(hijriYear: 1446, owedDays: 5)
        store.insertQadaFast(QadaFast(date: Date(timeIntervalSince1970: 0), hijriYear: 1446))
        let reopened = HidayahStore(makeContainer: {
            try HidayahStore.makeContainer(at: url)
        })

        // Assert
        let ledger = reopened.loadQadaLedger()
        XCTAssertEqual(ledger.years.map(\.owedDays), [5])
        XCTAssertEqual(ledger.years.map(\.madeUpDays), [1])
    }

    // MARK: - Helpers

    /// Writes a store with the shipped V1 schema only, as an installed copy
    /// of the app from before the Qada tracker would have.
    private func writeV1Store(at url: URL, taskID: UUID) throws {
        let schema = Schema(versionedSchema: HidayahSchemaV1.self)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, url: url)]
        )
        let context = ModelContext(container)

        context.insert(
            HidayahSchemaV1.StoredTask(
                id: taskID,
                name: "Fajr prayer",
                categoryID: "default_\(DefaultCategory.fajr.rawValue)",
                isCompleted: true,
                sortOrder: 0
            )
        )
        let day = HidayahSchemaV1.StoredDay(dayKey: "2026-11-01", payload: Data())
        day.completedCount = 4
        day.totalCount = 5
        day.points = 40
        context.insert(day)
        context.insert(HidayahSchemaV1.StoredBookmark(surahNumber: 18, numberInSurah: 10))
        try context.save()
    }
}
