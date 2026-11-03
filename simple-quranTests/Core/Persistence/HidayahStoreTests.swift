//
//  HidayahStoreTests.swift
//  simple-quranTests
//

import SwiftData
import XCTest
@testable import simple_quran

@MainActor
final class HidayahStoreTests: XCTestCase {
    private var sut: HidayahStore!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        sut = makeInMemoryStore()
    }

    override func tearDown() async throws {
        resetStorage()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Opening

    func test_init_should_bePersistentWhenContainerOpens() {
        // Arrange
        resetStorage()

        // Act
        let store = makeInMemoryStore()

        // Assert
        XCTAssertTrue(store.isPersistent)
        XCTAssertNil(store.loadError)
        XCTAssertEqual(Storage.load(key: .hasMigratedToSwiftData) as? Bool, true)
    }

    func test_init_should_fallBackToMemoryWhenContainerFails() {
        // Arrange
        resetStorage()

        // Act
        let store = makeFailingStore()

        // Assert
        XCTAssertFalse(store.isPersistent)
        XCTAssertTrue(store.loadError is CoreTestError)
        XCTAssertNil(Storage.load(key: .hasMigratedToSwiftData))
    }

    func test_init_should_stillStoreDataInMemoryWhenContainerFails() {
        // Arrange
        let store = makeFailingStore()

        // Act
        store.saveTasks([makeTask("Fajr prayer")])

        // Assert
        XCTAssertEqual(store.loadTrackerData().tasks.map(\.name), ["Fajr prayer"])
    }

    func test_reconnectIfNeeded_should_returnTrueWithoutReopeningWhenPersistent() {
        // Arrange
        let factory = FlakyContainerFactory(failures: 0)
        let store = HidayahStore(makeContainer: factory.make)

        // Act
        let result = store.reconnectIfNeeded()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(factory.attempts, 1)
    }

    func test_reconnectIfNeeded_should_openStoreOnceContainerRecovers() {
        // Arrange
        let factory = FlakyContainerFactory(failures: 1)
        let store = HidayahStore(makeContainer: factory.make)
        resetStorage()

        // Act
        let result = store.reconnectIfNeeded()

        // Assert
        XCTAssertTrue(result)
        XCTAssertTrue(store.isPersistent)
        XCTAssertNil(store.loadError)
        XCTAssertEqual(factory.attempts, 2)
        XCTAssertEqual(Storage.load(key: .hasMigratedToSwiftData) as? Bool, true)
    }

    func test_reconnectIfNeeded_should_returnFalseWhileContainerStillFails() {
        // Arrange
        let factory = FlakyContainerFactory(failures: 2)
        let store = HidayahStore(makeContainer: factory.make)

        // Act
        let result = store.reconnectIfNeeded()

        // Assert
        XCTAssertFalse(result)
        XCTAssertFalse(store.isPersistent)
        XCTAssertNotNil(store.loadError)
    }

    func test_reconnectIfNeeded_should_discardDataWrittenInMemory() {
        // Arrange
        let factory = FlakyContainerFactory(failures: 1)
        let store = HidayahStore(makeContainer: factory.make)
        store.saveTasks([makeTask("Temporary")])

        // Act
        store.reconnectIfNeeded()

        // Assert
        XCTAssertTrue(store.loadTrackerData().tasks.isEmpty)
    }

    func test_storeErrorDescription_should_describeMissingAppGroup() {
        // Arrange
        let error = HidayahStore.StoreError.appGroupUnavailable

        // Act
        let description = error.errorDescription

        // Assert
        XCTAssertEqual(description, "App Group container is unavailable.")
    }

    func test_makePersistentContainer_should_openStoreWhenAppGroupExists() {
        // Arrange
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.hasifofficial.simple-quran"
        )

        // Act & Assert
        if groupURL == nil {
            XCTAssertThrowsError(try HidayahStore.makePersistentContainer()) { error in
                guard case HidayahStore.StoreError.appGroupUnavailable = error else {
                    return XCTFail("Unexpected error \(error)")
                }
            }
        } else {
            XCTAssertNoThrow(try HidayahStore.makePersistentContainer())
        }
    }

    func test_shared_should_openUnderTests() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let shared = HidayahStore.shared

        // Assert
        XCTAssertTrue(shared.isPersistent)
    }

    // MARK: - Tasks

    func test_saveTasks_should_roundTripTasksInOrder() {
        // Arrange
        let custom = CustomCategory(name: "Charity", icon: "heart")
        let tasks = [
            makeTask("Fajr prayer", isCompleted: true),
            makeTask("Give alms", category: .custom(custom)),
            makeTask("Isha prayer", category: .default(.isha))
        ]
        sut.saveCategories([custom])

        // Act
        sut.saveTasks(tasks)

        // Assert
        let loaded = sut.loadTrackerData().tasks
        XCTAssertEqual(loaded.map(\.id), tasks.map(\.id))
        XCTAssertEqual(loaded.map(\.isCompleted), [true, false, false])
        XCTAssertEqual(loaded[1].category, .custom(custom))
        XCTAssertEqual(loaded[2].category, .default(.isha))
    }

    func test_saveTasks_should_writeOnlyChangedAndNewTasks() {
        // Arrange
        var tasks = [makeTask("A"), makeTask("B")]
        sut.saveTasks(tasks)
        tasks[0].name = "A edited"
        tasks[1].name = "B edited"
        tasks.append(makeTask("C"))

        // Act
        sut.saveTasks(tasks, changedIDs: [tasks[0].id])

        // Assert
        XCTAssertEqual(sut.loadTrackerData().tasks.map(\.name), ["A edited", "B", "C"])
    }

    func test_saveTasks_should_deleteRequestedTasks() {
        // Arrange
        let tasks = [makeTask("A"), makeTask("B")]
        sut.saveTasks(tasks)

        // Act
        sut.saveTasks([tasks[1]], changedIDs: [], deletedIDs: [tasks[0].id, UUID()])

        // Assert
        XCTAssertEqual(sut.loadTrackerData().tasks.map(\.name), ["B"])
    }

    func test_saveTasks_should_removeMissingTasksOnFullSave() {
        // Arrange
        let tasks = [makeTask("A"), makeTask("B")]
        sut.saveTasks(tasks)

        // Act
        sut.saveTasks([tasks[1]])

        // Assert
        XCTAssertEqual(sut.loadTrackerData().tasks.map(\.name), ["B"])
    }

    func test_saveTasks_should_keepMissingTasksOnPartialSave() {
        // Arrange
        let tasks = [makeTask("A"), makeTask("B")]
        sut.saveTasks(tasks)

        // Act
        sut.saveTasks([tasks[1]], changedIDs: [tasks[1].id])

        // Assert
        XCTAssertEqual(sut.loadTrackerData().tasks.count, 2)
    }

    func test_loadTrackerData_should_fallBackForUnknownCustomCategory() {
        // Arrange
        let orphan = CustomCategory(name: "Deleted", icon: "trash")
        sut.saveTasks([makeTask("Orphan", category: .custom(orphan))])

        // Act
        let task = sut.loadTrackerData().tasks.first

        // Assert
        XCTAssertEqual(task?.category.name, "Custom")
        XCTAssertEqual(task?.category.icon, "folder")
    }

    func test_loadTrackerData_should_fallBackForMalformedCustomCategoryID() {
        // Arrange
        sut.context.insert(
            StoredTask(id: UUID(), name: "Bad", categoryID: "custom_not-a-uuid", isCompleted: false, sortOrder: 0)
        )

        // Act
        let task = sut.loadTrackerData().tasks.first

        // Assert
        XCTAssertEqual(task?.category.name, "Custom")
    }

    func test_loadTrackerData_should_dropTasksWithUnknownCategory() {
        // Arrange
        sut.context.insert(
            StoredTask(id: UUID(), name: "Old", categoryID: "default_Removed", isCompleted: false, sortOrder: 0)
        )
        sut.context.insert(
            StoredTask(id: UUID(), name: "Junk", categoryID: "unknown", isCompleted: false, sortOrder: 1)
        )
        sut.saveTasks([makeTask("Kept")], changedIDs: [])

        // Act
        let tasks = sut.loadTrackerData().tasks

        // Assert
        XCTAssertEqual(tasks.map(\.name), ["Kept"])
    }

    func test_loadTrackerData_should_readActiveAndStartDayFromStorage() {
        // Arrange
        Storage.save(.trackerActiveDayKey, "2026-03-10")
        Storage.save(.trackerStartDayKey, "2026-03-01")

        // Act
        let snapshot = sut.loadTrackerData()

        // Assert
        XCTAssertEqual(snapshot.activeDayKey, "2026-03-10")
        XCTAssertEqual(snapshot.startDayKey, "2026-03-01")
    }

    // MARK: - Categories

    func test_saveCategories_should_insertUpdateAndRemoveCategories() {
        // Arrange
        var first = CustomCategory(name: "One")
        let second = CustomCategory(name: "Two")
        sut.saveCategories([first, second])
        first.name = "One edited"
        first.icon = "star"
        let third = CustomCategory(name: "Three")

        // Act
        sut.saveCategories([third, first])

        // Assert
        let loaded = sut.loadTrackerData().customCategories
        XCTAssertEqual(loaded.map(\.name), ["Three", "One edited"])
        XCTAssertEqual(loaded.last?.icon, "star")
    }

    // MARK: - Days

    func test_saveDay_should_storeRecordAndSummary() {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 2, total: 3)

        // Act
        sut.saveDay(record)

        // Assert
        XCTAssertEqual(sut.loadDay("2026-03-10"), record)
        let summary = sut.loadHistorySummaries().first
        XCTAssertEqual(summary?.completedCount, 2)
        XCTAssertEqual(summary?.totalCount, 3)
        XCTAssertEqual(summary?.points, 20)
        XCTAssertEqual(summary?.tasks.isEmpty, true)
    }

    func test_saveDay_should_replaceExistingRecordForSameDay() {
        // Arrange
        sut.saveDay(makeRecord("2026-03-10", completed: 1, total: 2))
        let updated = makeRecord("2026-03-10", completed: 2, total: 2)

        // Act
        sut.saveDay(updated)

        // Assert
        XCTAssertEqual(sut.loadDay("2026-03-10"), updated)
        XCTAssertEqual(sut.loadHistorySummaries().count, 1)
        XCTAssertEqual(sut.loadHistorySummaries().first?.points, 70)
    }

    func test_loadHistorySummaries_should_sortByDay() {
        // Arrange
        sut.saveDay(makeRecord("2026-03-10", completed: 1, total: 2))
        sut.saveDay(makeRecord("2026-01-05", completed: 1, total: 2))

        // Act
        let summaries = sut.loadHistorySummaries()

        // Assert
        XCTAssertEqual(summaries.map(\.dayKey), ["2026-01-05", "2026-03-10"])
    }

    func test_loadHistorySummaries_should_backfillCountsFromPayload() throws {
        // Arrange
        let record = makeRecord("2026-03-10", completed: 1, total: 2)
        sut.context.insert(
            StoredDay(dayKey: record.dayKey, payload: try JSONEncoder().encode(record))
        )

        // Act
        let first = sut.loadHistorySummaries()
        let second = sut.loadHistorySummaries()

        // Assert
        XCTAssertEqual(first, [record])
        XCTAssertEqual(second.first?.totalCount, 2)
        XCTAssertEqual(second.first?.tasks.isEmpty, true)
    }

    func test_loadHistorySummaries_should_returnEmptySummaryForCorruptPayload() {
        // Arrange
        sut.context.insert(StoredDay(dayKey: "2026-03-10", payload: Data("x".utf8)))

        // Act
        let summary = sut.loadHistorySummaries().first

        // Assert
        XCTAssertEqual(summary?.dayKey, "2026-03-10")
        XCTAssertEqual(summary?.totalCount, 0)
        XCTAssertEqual(summary?.points, 0)
        XCTAssertNil(sut.loadDay("2026-03-10"))
    }

    func test_deleteDay_should_removeStoredDay() {
        // Arrange
        sut.saveDay(makeRecord("2026-03-10", completed: 1, total: 2))

        // Act
        sut.deleteDay("2026-03-10")
        sut.deleteDay("2026-03-11")

        // Assert
        XCTAssertNil(sut.loadDay("2026-03-10"))
        XCTAssertTrue(sut.loadHistorySummaries().isEmpty)
    }

    func test_loadDay_should_returnNilForMissingDay() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let record = sut.loadDay("2026-03-10")

        // Assert
        XCTAssertNil(record)
    }

    // MARK: - Preferences

    func test_saveActiveState_should_writeProvidedKeysOnly() {
        // Arrange
        Storage.save(.trackerStartDayKey, "2026-01-01")

        // Act
        sut.saveActiveState(activeDayKey: "2026-03-10", startDayKey: nil)

        // Assert
        XCTAssertEqual(Storage.load(key: .trackerActiveDayKey) as? String, "2026-03-10")
        XCTAssertEqual(Storage.load(key: .trackerStartDayKey) as? String, "2026-01-01")
    }

    func test_saveActiveState_should_writeStartDay() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        sut.saveActiveState(activeDayKey: nil, startDayKey: "2026-03-01")

        // Assert
        XCTAssertNil(Storage.load(key: .trackerActiveDayKey))
        XCTAssertEqual(Storage.load(key: .trackerStartDayKey) as? String, "2026-03-01")
    }

    func test_saveActiveState_should_skipPreferencesWhenNotPersistent() {
        // Arrange
        let store = makeFailingStore()

        // Act
        store.saveActiveState(activeDayKey: "2026-03-10", startDayKey: "2026-03-01")

        // Assert
        XCTAssertNil(Storage.load(key: .trackerActiveDayKey))
        XCTAssertNil(Storage.load(key: .trackerStartDayKey))
    }

    func test_resetTracker_should_deleteTrackerDataAndPreferences() {
        // Arrange
        sut.saveTasks([makeTask("A")])
        sut.saveCategories([CustomCategory(name: "One")])
        sut.saveDay(makeRecord("2026-03-10", completed: 1, total: 1))
        sut.toggleBookmark(SurahBookmark(surahNumber: 1, numberInSurah: 1))
        sut.saveActiveState(activeDayKey: "2026-03-10", startDayKey: "2026-03-01")

        // Act
        sut.resetTracker()

        // Assert
        let snapshot = sut.loadTrackerData()
        XCTAssertTrue(snapshot.tasks.isEmpty)
        XCTAssertTrue(snapshot.customCategories.isEmpty)
        XCTAssertTrue(snapshot.history.isEmpty)
        XCTAssertNil(snapshot.activeDayKey)
        XCTAssertNil(snapshot.startDayKey)
        XCTAssertEqual(sut.bookmarks().count, 1, "bookmarks are not tracker data")
    }

    func test_resetTracker_should_keepPreferencesWhenNotPersistent() {
        // Arrange
        let store = makeFailingStore()
        store.saveTasks([makeTask("A")])
        Storage.save(.trackerActiveDayKey, "2026-03-10")
        Storage.save(.trackerStartDayKey, "2026-03-01")

        // Act
        store.resetTracker()

        // Assert
        XCTAssertTrue(store.loadTrackerData().tasks.isEmpty)
        XCTAssertEqual(Storage.load(key: .trackerActiveDayKey) as? String, "2026-03-10")
        XCTAssertEqual(Storage.load(key: .trackerStartDayKey) as? String, "2026-03-01")
    }

    // MARK: - Bookmarks

    func test_toggleBookmark_should_addMissingBookmark() {
        // Arrange
        let bookmark = SurahBookmark(surahNumber: 18, numberInSurah: 10)

        // Act
        let result = sut.toggleBookmark(bookmark)

        // Assert
        XCTAssertEqual(result, [bookmark])
        XCTAssertEqual(sut.bookmarks(), [bookmark])
    }

    func test_toggleBookmark_should_removeExistingBookmark() {
        // Arrange
        let bookmark = SurahBookmark(surahNumber: 18, numberInSurah: 10)
        sut.toggleBookmark(bookmark)

        // Act
        let result = sut.toggleBookmark(bookmark)

        // Assert
        XCTAssertTrue(result.isEmpty)
        XCTAssertTrue(sut.bookmarks().isEmpty)
    }

    func test_bookmarks_should_listNewestFirst() {
        // Arrange
        let older = SurahBookmark(surahNumber: 1, numberInSurah: 1)
        let newer = SurahBookmark(surahNumber: 2, numberInSurah: 5)
        sut.toggleBookmark(older)
        Thread.sleep(forTimeInterval: 0.01)
        sut.toggleBookmark(newer)

        // Act
        let bookmarks = sut.bookmarks()

        // Assert
        XCTAssertEqual(bookmarks, [newer, older])
    }
}
