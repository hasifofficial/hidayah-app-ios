//
//  TaskManagerTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TaskManagerTests: XCTestCase {
    private var store: HidayahStore!
    private var center: FakeNotificationCenter!
    private var clock: TestClock!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        store = makeInMemoryStore()
        center = FakeNotificationCenter()
        clock = TestClock(TestClock.date(year: 2026, month: 3, day: 10))
    }

    override func tearDown() async throws {
        resetStorage()
        store = nil
        center = nil
        clock = nil
        try await super.tearDown()
    }

    private func makeSUT() -> TaskManager {
        makeTaskManager(store: store, center: center, clock: clock)
    }

    /// Seeds two tasks so the manager skips the default list.
    @discardableResult
    private func seedTwoTasks() -> [TaskDetails] {
        let tasks = [makeTask("Fajr prayer"), makeTask("Dhuha prayer", category: .default(.dhuha))]
        store.saveTasks(tasks)
        return tasks
    }

    // MARK: - Loading

    func test_init_should_seedDefaultTasksWhenStoreIsEmpty() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.tasks.count, 67)
        XCTAssertTrue(sut.tasks.allSatisfy { !$0.isCompleted })
        XCTAssertEqual(store.loadTrackerData().tasks.map(\.id), sut.tasks.map(\.id))
    }

    func test_init_should_setActiveAndStartDayToToday() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertEqual(sut.startDayKey, "2026-03-10")
    }

    func test_addTask_should_persistActiveAndStartDay() {
        // Arrange
        let sut = makeSUT()

        // Act
        sut.addTask(name: "Read Quran", category: .default(.recitation))

        // Assert
        XCTAssertEqual(Storage.load(key: .trackerActiveDayKey) as? String, "2026-03-10")
        XCTAssertEqual(Storage.load(key: .trackerStartDayKey) as? String, "2026-03-10")
    }

    func test_init_should_loadSavedTasksInsteadOfDefaults() {
        // Arrange
        let seeded = seedTwoTasks()

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.tasks.map(\.id), seeded.map(\.id))
    }

    func test_init_should_rollOverWhenSavedActiveDayIsInThePast() {
        // Arrange
        let tasks = [makeTask("Fajr prayer", isCompleted: true), makeTask("Isha prayer")]
        store.saveTasks(tasks)
        Storage.save(.trackerActiveDayKey, "2026-03-09")
        Storage.save(.trackerStartDayKey, "2026-03-01")

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertEqual(sut.startDayKey, "2026-03-01")
        XCTAssertTrue(sut.tasks.allSatisfy { !$0.isCompleted })
        XCTAssertEqual(sut.record(for: "2026-03-09")?.completedCount, 1)
    }

    // MARK: - Editing

    func test_addTask_should_appendAndPersistTask() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.addTask(name: "Read Quran", category: .default(.recitation))

        // Assert
        XCTAssertEqual(sut.tasks.last?.name, "Read Quran")
        XCTAssertEqual(store.loadTrackerData().tasks.last?.name, "Read Quran")
        XCTAssertEqual(store.loadTrackerData().tasks.count, 3)
    }

    func test_updateTask_should_renameAndRecategoriseTask() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.updateTask(task: seeded[0], newName: "Subuh", newCategory: .default(.morning))

        // Assert
        let stored = store.loadTrackerData().tasks[0]
        XCTAssertEqual(sut.tasks[0].name, "Subuh")
        XCTAssertEqual(stored.name, "Subuh")
        XCTAssertEqual(stored.category.id, simple_quran.Category.default(.morning).id)
    }

    func test_updateTask_should_ignoreUnknownTask() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.updateTask(task: makeTask("Ghost"), newName: "Renamed", newCategory: .default(.isha))

        // Assert
        XCTAssertEqual(sut.tasks.map(\.name), ["Fajr prayer", "Dhuha prayer"])
    }

    func test_deleteTask_should_removeTaskFromMemoryAndStore() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.deleteTask(task: seeded[0])

        // Assert
        XCTAssertEqual(sut.tasks.map(\.id), [seeded[1].id])
        XCTAssertEqual(store.loadTrackerData().tasks.map(\.id), [seeded[1].id])
    }

    func test_addCustomCategory_should_persistCategoryAndListItAfterDefaults() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.addCustomCategory(name: "Charity", icon: "heart")

        // Assert
        let categories = sut.allCategories()
        XCTAssertEqual(categories.count, DefaultCategory.allCases.count + 1)
        XCTAssertEqual(categories.last?.name, "Charity")
        XCTAssertEqual(categories.last?.icon, "heart")
        XCTAssertEqual(store.loadTrackerData().customCategories.map(\.name), ["Charity"])
    }

    func test_tasksForCategory_should_returnOnlyTasksInThatCategory() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        let dhuhaTasks = sut.tasks(for: .default(.dhuha))

        // Assert
        XCTAssertEqual(dhuhaTasks.map(\.name), ["Dhuha prayer"])
    }

    // MARK: - Completion

    func test_toggleTaskCompletion_should_markTaskCompleted() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: seeded[0])

        // Assert
        XCTAssertTrue(sut.tasks[0].isCompleted)
        XCTAssertTrue(store.loadTrackerData().tasks[0].isCompleted)
        XCTAssertEqual(sut.todayRecord?.completedCount, 1)
        XCTAssertEqual(store.loadDay("2026-03-10")?.completedCount, 1)
    }

    func test_toggleTaskCompletion_should_notifySchedulerOfMilestone() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: seeded[0])

        // Assert
        XCTAssertEqual(
            center.scheduled.map(\.identifier),
            [NotificationIdentifier.trackerMilestonePrefix + "2026-03-10-50"]
        )
    }

    func test_toggleTaskCompletion_should_removeTodayRecordWhenUntoggled() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])

        // Act
        sut.toggleTaskCompletion(task: seeded[0])

        // Assert
        XCTAssertFalse(sut.tasks[0].isCompleted)
        XCTAssertNil(sut.todayRecord)
        XCTAssertNil(store.loadDay("2026-03-10"))
    }

    func test_toggleTaskCompletion_should_ignoreUnknownTask() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: makeTask("Ghost"))

        // Assert
        XCTAssertTrue(sut.tasks.allSatisfy { !$0.isCompleted })
        XCTAssertTrue(center.scheduled.isEmpty)
    }

    func test_toggleTaskCompletion_should_rollOverBeforeTogglingOnNewDay() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        clock.advance(days: 1)

        // Act
        sut.toggleTaskCompletion(task: seeded[1])

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-11")
        XCTAssertEqual(sut.tasks.map(\.isCompleted), [false, true])
        XCTAssertEqual(sut.record(for: "2026-03-10")?.tasks.first?.isCompleted, true)
        XCTAssertEqual(sut.history.map(\.dayKey), ["2026-03-10", "2026-03-11"])
    }

    // MARK: - Day rollover

    func test_refreshForCurrentDay_should_archiveYesterdayAndResetTasks() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        clock.advance(days: 1)

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-11")
        XCTAssertEqual(sut.startDayKey, "2026-03-10")
        XCTAssertTrue(sut.tasks.allSatisfy { !$0.isCompleted })
        XCTAssertFalse(store.loadTrackerData().tasks.contains { $0.isCompleted })
        XCTAssertEqual(sut.history.map(\.dayKey), ["2026-03-10"])
        XCTAssertNil(sut.todayRecord)
    }

    func test_refreshForCurrentDay_should_waitForResetTime_when_pastMidnight() {
        // Arrange
        TrackerDayKey.dayStartMinutes = 4 * 60
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        clock.now = TestClock.date(year: 2026, month: 3, day: 11, hour: 2)

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertTrue(sut.tasks[0].isCompleted)
    }

    func test_refreshForCurrentDay_should_rollOver_when_resetTimePasses() {
        // Arrange
        TrackerDayKey.dayStartMinutes = 4 * 60
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        clock.now = TestClock.date(year: 2026, month: 3, day: 11, hour: 5)

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-11")
        XCTAssertTrue(sut.tasks.allSatisfy { !$0.isCompleted })
        XCTAssertEqual(sut.history.map(\.dayKey), ["2026-03-10"])
    }

    func test_setDayStartMinutes_should_keepTodaysProgress_when_resetMovesLater() {
        // Arrange
        clock.now = TestClock.date(year: 2026, month: 3, day: 10, hour: 2)
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])

        // Act
        sut.setDayStartMinutes(4 * 60)

        // Assert
        XCTAssertEqual(sut.dayStartMinutes, 240)
        XCTAssertEqual(Storage.load(key: .trackerDayStartMinutes) as? Int, 240)
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertTrue(sut.tasks[0].isCompleted)
    }

    func test_setDayStartMinutes_should_ignoreUnsupportedTimes() {
        // Arrange
        let sut = makeSUT()

        // Act
        sut.setDayStartMinutes(15 * 60)

        // Assert
        XCTAssertEqual(sut.dayStartMinutes, 0)
        XCTAssertNil(Storage.load(key: .trackerDayStartMinutes))
    }

    func test_resetAll_should_restoreMidnightReset() {
        // Arrange
        let sut = makeSUT()
        sut.setDayStartMinutes(3 * 60)

        // Act
        sut.resetAll()

        // Assert
        XCTAssertEqual(sut.dayStartMinutes, 0)
    }

    func test_refreshForCurrentDay_should_doNothingOnSameDay() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertTrue(sut.tasks[0].isCompleted)
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
    }

    func test_refreshForCurrentDay_should_adoptTodayWhenActiveDayIsMissing() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.activeDayKey = nil
        sut.startDayKey = nil

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertEqual(sut.startDayKey, "2026-03-10")
    }

    func test_refreshForCurrentDay_should_keepStartDayWhenActiveDayIsMissing() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.activeDayKey = nil
        sut.startDayKey = "2026-01-01"

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertEqual(sut.startDayKey, "2026-01-01")
    }

    func test_refreshForCurrentDay_should_setStartDayToPreviousDayWhenMissing() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.startDayKey = nil
        clock.advance(days: 2)

        // Act
        sut.refreshForCurrentDay()

        // Assert
        XCTAssertEqual(sut.activeDayKey, "2026-03-12")
        XCTAssertEqual(sut.startDayKey, "2026-03-10")
    }

    func test_dayChangedNotification_should_rollOverToNewDay() async {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        clock.advance(days: 1)

        // Act
        NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)

        // Assert
        await waitUntil { sut.activeDayKey == "2026-03-11" }
        XCTAssertFalse(sut.tasks[0].isCompleted)
    }

    // MARK: - Reset

    func test_resetDailyTasks_should_clearCompletionAndTodayHistory() async {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.toggleTaskCompletion(task: seeded[0])
        sut.toggleTaskCompletion(task: seeded[1])

        // Act
        sut.resetDailyTasks()

        // Assert
        await waitUntil { sut.tasks.allSatisfy { !$0.isCompleted } }
        XCTAssertTrue(sut.history.isEmpty)
        XCTAssertNil(store.loadDay("2026-03-10"))
        XCTAssertNil(Storage.load(key: .trackerCheerState))
        XCTAssertEqual(sut.tasks.count, 2)
    }

    func test_resetAll_should_restoreDefaultsAndClearHistory() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()
        sut.addCustomCategory(name: "Charity")
        sut.toggleTaskCompletion(task: seeded[0])

        // Act
        sut.resetAll()

        // Assert
        XCTAssertEqual(sut.tasks.count, 67)
        XCTAssertTrue(sut.customCategories.isEmpty)
        XCTAssertTrue(sut.history.isEmpty)
        XCTAssertEqual(sut.activeDayKey, "2026-03-10")
        XCTAssertEqual(sut.startDayKey, "2026-03-10")
        XCTAssertTrue(
            center.removed.contains([NotificationIdentifier.trackerDailyCheer.rawValue])
        )
    }

    // MARK: - History

    func test_recordsInMonth_should_returnOnlyThatMonthsRecords() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.history = [
            makeRecord("2026-02-28", completed: 1, total: 2),
            makeRecord("2026-03-01", completed: 1, total: 2),
            makeRecord("2026-03-31", completed: 2, total: 2),
            makeRecord("2026-04-01", completed: 1, total: 2)
        ]

        // Act
        let records = sut.records(in: TestClock.date(year: 2026, month: 3, day: 15))

        // Assert
        XCTAssertEqual(records.map(\.dayKey), ["2026-03-01", "2026-03-31"])
    }

    func test_recordForDay_should_loadFullRecordForSummary() {
        // Arrange
        seedTwoTasks()
        store.saveDay(makeRecord("2026-03-01", completed: 1, total: 2))
        let sut = makeSUT()
        XCTAssertTrue(sut.history.first?.tasks.isEmpty == true)

        // Act
        let record = sut.record(for: "2026-03-01")

        // Assert
        XCTAssertEqual(record?.tasks.count, 2)
        XCTAssertEqual(sut.history.first?.tasks.count, 2)
    }

    func test_recordForDay_should_returnSummaryWhenFullRecordIsGone() {
        // Arrange
        seedTwoTasks()
        store.saveDay(makeRecord("2026-03-01", completed: 1, total: 2))
        let sut = makeSUT()
        store.deleteDay("2026-03-01")

        // Act
        let record = sut.record(for: "2026-03-01")

        // Assert
        XCTAssertEqual(record?.completedCount, 1)
        XCTAssertEqual(record?.tasks.isEmpty, true)
    }

    func test_recordForDay_should_returnNilForUnknownDay() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()

        // Act
        let record = sut.record(for: "1999-01-01")

        // Assert
        XCTAssertNil(record)
    }

    func test_recordForDay_should_rebuildLookupAfterHistoryIsReplaced() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.history = [makeRecord("2026-03-05", completed: 2, total: 2)]

        // Act
        let record = sut.record(for: "2026-03-05")

        // Assert
        XCTAssertEqual(record?.isPerfectDay, true)
    }

    // MARK: - Stats

    func test_stats_should_reflectCompletedTasks() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: seeded[0])

        // Assert
        XCTAssertEqual(sut.stats.totalPoints, 10)
        XCTAssertEqual(sut.stats.currentStreak, 1)
    }

    func test_stats_should_returnCachedValueUntilInvalidated() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        let initial = sut.stats.totalPoints

        // Act
        sut.history = [makeRecord("2026-03-05", completed: 2, total: 2)]
        let cached = sut.stats.totalPoints
        sut.upsertTodayRecord()
        let refreshed = sut.stats.totalPoints

        // Assert
        XCTAssertEqual(initial, 0)
        XCTAssertEqual(cached, 0)
        XCTAssertEqual(refreshed, 70)
    }

    // MARK: - Widget

    func test_updateWidget_should_writeSnapshotForToday() {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: seeded[0])

        // Assert
        let context = loadWidgetContext()
        XCTAssertEqual(context?.completedTasks, 1)
        XCTAssertEqual(context?.totalTasks, 2)
        XCTAssertEqual(context?.progress, 0.5)
        XCTAssertEqual(context?.dayKey, "2026-03-10")
        XCTAssertEqual(context?.upcomingTasks.map(\.id), [seeded[1].id])
        XCTAssertEqual(context?.resetUpcomingTasks?.map(\.id), seeded.map(\.id))
        XCTAssertEqual(context?.resetUpcomingTasks?.contains { $0.isCompleted }, false)
    }

    func test_updateWidget_should_limitUpcomingTasksToFive() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        _ = makeSUT()

        // Assert
        let context = loadWidgetContext()
        XCTAssertEqual(context?.upcomingTasks.count, 5)
        XCTAssertEqual(context?.resetUpcomingTasks?.count, 5)
        XCTAssertEqual(context?.totalTasks, 67)
    }

    func test_updateWidget_should_reportZeroProgressWithoutTasks() {
        // Arrange
        seedTwoTasks()
        let sut = makeSUT()
        sut.tasks = []

        // Act
        sut.updateWidget()

        // Assert
        XCTAssertEqual(loadWidgetContext()?.progress, 0)
        XCTAssertEqual(loadWidgetContext()?.totalTasks, 0)
    }

    func test_updateWidget_should_keepSnapshotAfterTimelineReload() async {
        // Arrange
        let seeded = seedTwoTasks()
        let sut = makeSUT()

        // Act
        sut.toggleTaskCompletion(task: seeded[0])
        try? await Task.sleep(for: .milliseconds(800))

        // Assert
        XCTAssertEqual(loadWidgetContext()?.completedTasks, 1)
    }

    // MARK: - Store unavailable

    func test_updateWidget_should_notWriteSnapshotWhenStoreIsNotPersistent() {
        // Arrange
        store = makeFailingStore()

        // Act
        let sut = makeSUT()

        // Assert
        XCTAssertEqual(sut.tasks.count, 67)
        XCTAssertNil(Storage.load(key: .widgetContext))
        XCTAssertNil(Storage.load(key: .trackerActiveDayKey))
    }

    func test_loadTasks_should_reconnectToStoreThatRecovered() {
        // Arrange
        let factory = FlakyContainerFactory(failures: 1)
        store = HidayahStore(makeContainer: factory.make)
        XCTAssertFalse(store.isPersistent)

        // Act
        _ = makeSUT()

        // Assert
        XCTAssertTrue(store.isPersistent)
        XCTAssertEqual(loadWidgetContext()?.totalTasks, 67)
    }
}
