//
//  ToggleTaskIntentTests.swift
//  app-widgetTests
//

import XCTest

@MainActor
final class ToggleTaskIntentTests: XCTestCase {
    private var store: HidayahStore!
    private var manager: TaskManager!

    override func setUp() {
        super.setUp()
        resetStorage()
        // `TaskManager.shared` cannot be used here: its default scheduler
        // asks for `UNUserNotificationCenter.current()`, which throws in a
        // test bundle without a host app. A manager over a fresh in-memory
        // store with a fake notification center stands in for it.
        let store = HidayahStore(makeContainer: HidayahStore.makeInMemoryContainer)
        let manager = TaskManager(
            store: store,
            scheduler: TrackerNotificationScheduler(center: FakeNotificationCenter())
        )
        self.store = store
        self.manager = manager
        ToggleTaskIntent.storeOverride = store
        ToggleTaskIntent.taskManagerOverride = manager
    }

    override func tearDown() {
        ToggleTaskIntent.taskManagerOverride = nil
        ToggleTaskIntent.storeOverride = nil
        store = nil
        manager = nil
        resetStorage()
        super.tearDown()
    }

    func test_overrides_should_beNil_byDefault() {
        // Arrange
        ToggleTaskIntent.taskManagerOverride = nil
        ToggleTaskIntent.storeOverride = nil

        // Act
        let overrides: [AnyObject?] = [
            ToggleTaskIntent.taskManagerOverride,
            ToggleTaskIntent.storeOverride
        ]

        // Assert
        XCTAssertTrue(overrides.allSatisfy { $0 == nil })
    }

    func test_perform_should_checkSharedStore_when_noStoreOverrideIsSet() async throws {
        // Arrange
        ToggleTaskIntent.storeOverride = nil
        XCTAssertTrue(HidayahStore.shared.isPersistent)
        let task = try XCTUnwrap(manager.tasks.first)
        let intent = ToggleTaskIntent(id: task.id.uuidString)

        // Act
        _ = try await intent.perform()

        // Assert
        XCTAssertEqual(manager.tasks.first { $0.id == task.id }?.isCompleted, true)
    }

    func test_init_should_keepTaskID() {
        // Arrange
        let id = UUID().uuidString

        // Act
        let intent = ToggleTaskIntent(id: id)

        // Assert
        XCTAssertEqual(intent.id, id)
    }

    func test_perform_should_completeTaskWithMatchingID() async throws {
        // Arrange
        let task = try XCTUnwrap(manager.tasks.first)
        XCTAssertFalse(task.isCompleted)
        let intent = ToggleTaskIntent(id: task.id.uuidString)

        // Act
        _ = try await intent.perform()

        // Assert
        let toggled = manager.tasks.first { $0.id == task.id }
        XCTAssertEqual(toggled?.isCompleted, true)
        XCTAssertEqual(manager.tasks.filter(\.isCompleted).count, 1)
    }

    func test_perform_should_persistToggle() async throws {
        // Arrange
        let task = try XCTUnwrap(manager.tasks.last)
        let intent = ToggleTaskIntent(id: task.id.uuidString)

        // Act
        _ = try await intent.perform()

        // Assert
        let stored = store.loadTrackerData().tasks.first { $0.id == task.id }
        XCTAssertEqual(stored?.isCompleted, true)
        let snapshot: WidgetContext? = Storage.loadObject(key: .widgetContext)
        XCTAssertEqual(snapshot?.completedTasks, 1)
    }

    func test_perform_should_uncompleteTask_when_performedTwice() async throws {
        // Arrange
        let task = try XCTUnwrap(manager.tasks.first)
        let intent = ToggleTaskIntent(id: task.id.uuidString)
        _ = try await intent.perform()

        // Act
        _ = try await intent.perform()

        // Assert
        let toggled = manager.tasks.first { $0.id == task.id }
        XCTAssertEqual(toggled?.isCompleted, false)
    }

    func test_perform_should_changeNothing_when_idIsUnknown() async throws {
        // Arrange
        let before = manager.tasks.map { "\($0.id)-\($0.isCompleted)" }
        let intent = ToggleTaskIntent(id: UUID().uuidString)

        // Act
        _ = try await intent.perform()

        // Assert
        let after = manager.tasks.map { "\($0.id)-\($0.isCompleted)" }
        XCTAssertEqual(after, before)
        XCTAssertFalse(before.isEmpty)
    }

    func test_perform_should_throwStoreError_when_storeIsNotPersistent() async throws {
        // Arrange
        let unavailableStore = makeUnavailableStore()
        let offlineManager = TaskManager(
            store: unavailableStore,
            scheduler: TrackerNotificationScheduler(center: FakeNotificationCenter())
        )
        ToggleTaskIntent.storeOverride = unavailableStore
        ToggleTaskIntent.taskManagerOverride = offlineManager
        let task = try XCTUnwrap(offlineManager.tasks.first)
        let intent = ToggleTaskIntent(id: task.id.uuidString)

        // Act
        var thrown: Error?
        do {
            _ = try await intent.perform()
        } catch {
            thrown = error
        }

        // Assert
        XCTAssertTrue(thrown is StoreUnavailableError)
        XCTAssertEqual(offlineManager.tasks.first { $0.id == task.id }?.isCompleted, false)
    }

    func test_title_should_useLocalizedKey() {
        // Arrange
        let expectedKey = "widget_toggle_task_title"

        // Act
        let title = ToggleTaskIntent.title

        // Assert
        XCTAssertEqual(title.key, expectedKey)
    }

    func test_emptyInit_should_createIntentWithoutTaskID() {
        // Arrange
        let make = { ToggleTaskIntent() }

        // Act
        let intent = make()

        // Assert
        XCTAssertTrue(type(of: intent) == ToggleTaskIntent.self)
    }
}
