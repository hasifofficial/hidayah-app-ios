//
//  WatchSyncServiceTests.swift
//  hidayah-app-tests
//

import WatchConnectivity
import XCTest
@testable import hidayah_app

@MainActor
final class WatchSyncServiceTests: XCTestCase {
    private var store: HidayahStore!
    private var clock: TestClock!

    override func setUp() async throws {
        try await super.setUp()
        resetStorage()
        store = makeInMemoryStore()
        clock = TestClock(TestClock.date(year: 2026, month: 3, day: 10))
    }

    override func tearDown() async throws {
        resetStorage()
        store = nil
        clock = nil
        try await super.tearDown()
    }

    private func makeManager(tasks: [TaskDetails]) -> TaskManager {
        store.saveTasks(tasks)
        return makeTaskManager(store: store, clock: clock)
    }

    // MARK: - Snapshot

    func test_makeSnapshot_should_describeTodayAndTheNextDay() {
        // Arrange
        let tasks = [makeTask("Fajr prayer", isCompleted: true), makeTask("Dhuha prayer")]
        let manager = makeManager(tasks: tasks)

        // Act
        let snapshot = WatchSyncService.makeSnapshot(from: manager, now: clock.now)

        // Assert
        XCTAssertEqual(snapshot.dayKey, "2026-03-10")
        XCTAssertEqual(snapshot.tasks.map(\.id), tasks.map(\.id))
        XCTAssertEqual(snapshot.tasks.map(\.isCompleted), [true, false])
        XCTAssertEqual(snapshot.currentStreak, 1)
        XCTAssertEqual(snapshot.nextDayKey, "2026-03-11")
        XCTAssertEqual(snapshot.generatedAt, clock.now)
        XCTAssertEqual(snapshot.nextDayStart, TrackerDayKey.nextDayStart(after: clock.now))
        XCTAssertEqual(
            snapshot.nextDayEnd,
            TestClock.date(year: 2026, month: 3, day: 12, hour: 0)
        )
    }

    // MARK: - Completions

    func test_handle_should_applyCompletionToTaskManager() {
        // Arrange
        let tasks = [makeTask("Fajr prayer"), makeTask("Dhuha prayer")]
        let manager = makeManager(tasks: tasks)
        let sut = WatchSyncService(session: nil, now: { self.clock.now })
        sut.start(taskManager: manager)

        // Act
        sut.handle(WatchTaskCompletion(taskID: tasks[0].id, isCompleted: true, dayKey: "2026-03-10"))

        // Assert
        XCTAssertTrue(manager.tasks[0].isCompleted)
        XCTAssertEqual(sut.makeSnapshot()?.tasks[0].isCompleted, true)
    }

    func test_didReceiveMessage_should_applyCompletionSentWithoutReply() async throws {
        // Arrange
        let tasks = [makeTask("Fajr prayer"), makeTask("Dhuha prayer")]
        let manager = makeManager(tasks: tasks)
        let sut = WatchSyncService(session: nil, now: { self.clock.now })
        sut.start(taskManager: manager)
        let completion = WatchTaskCompletion(taskID: tasks[1].id, isCompleted: true, dayKey: "2026-03-10")
        let payload = try XCTUnwrap(WatchMessage.payload(for: completion))

        // Act
        sut.session(.default, didReceiveMessage: payload)
        try await waitUntil { manager.tasks[1].isCompleted }

        // Assert
        XCTAssertTrue(manager.tasks[1].isCompleted)
        XCTAssertTrue(store.loadTrackerData().tasks[1].isCompleted)
    }

    func test_didReceiveMessageWithReply_should_applyCompletionAndReply() async throws {
        // Arrange
        let tasks = [makeTask("Fajr prayer")]
        let manager = makeManager(tasks: tasks)
        let sut = WatchSyncService(session: nil, now: { self.clock.now })
        sut.start(taskManager: manager)
        let completion = WatchTaskCompletion(taskID: tasks[0].id, isCompleted: true, dayKey: "2026-03-10")
        let payload = try XCTUnwrap(WatchMessage.payload(for: completion))
        let replied = expectation(description: "reply")

        var reply: [String: Any] = [:]

        // Act
        sut.session(.default, didReceiveMessage: payload) {
            reply = $0
            replied.fulfill()
        }
        await fulfillment(of: [replied], timeout: 1)

        // Assert
        XCTAssertTrue(manager.tasks[0].isCompleted)
        XCTAssertEqual(WatchMessage.snapshot(from: reply)?.tasks[0].isCompleted, true)
    }

    func test_didReceiveUserInfo_should_applyQueuedCompletion() async throws {
        // Arrange
        let tasks = [makeTask("Fajr prayer")]
        let manager = makeManager(tasks: tasks)
        let sut = WatchSyncService(session: nil, now: { self.clock.now })
        sut.start(taskManager: manager)
        let completion = WatchTaskCompletion(taskID: tasks[0].id, isCompleted: true, dayKey: "2026-03-10")
        let payload = try XCTUnwrap(WatchMessage.payload(for: completion))

        // Act
        sut.session(.default, didReceiveUserInfo: payload)
        try await waitUntil { manager.tasks[0].isCompleted }

        // Assert
        XCTAssertTrue(manager.tasks[0].isCompleted)
    }

    /// Delegate callbacks hop to the main actor in a task; give it a moment.
    private func waitUntil(
        timeout: TimeInterval = 1,
        _ condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func test_start_should_connectTrackerChanges() {
        // Arrange
        let manager = makeManager(tasks: [makeTask("Fajr prayer")])
        let sut = WatchSyncService(session: nil, now: { self.clock.now })

        // Act
        sut.start(taskManager: manager)

        // Assert
        XCTAssertNotNil(manager.onTrackerChange)
    }

    // MARK: - Payloads

    func test_payload_should_roundTripSnapshot() {
        // Arrange
        let manager = makeManager(tasks: [makeTask("Fajr prayer")])
        let snapshot = WatchSyncService.makeSnapshot(from: manager, now: clock.now)

        // Act
        let decoded = WatchMessage.payload(for: snapshot).flatMap(WatchMessage.snapshot(from:))

        // Assert
        XCTAssertEqual(decoded, snapshot)
    }

    func test_payload_should_roundTripCompletion() {
        // Arrange
        let completion = WatchTaskCompletion(taskID: UUID(), isCompleted: false, dayKey: "2026-03-10")

        // Act
        let decoded = WatchMessage.payload(for: completion).flatMap(WatchMessage.completion(from:))

        // Assert
        XCTAssertEqual(decoded, completion)
    }

    func test_completion_should_ignoreUnrelatedPayload() {
        // Arrange
        let payload: [String: Any] = [WatchMessage.requestSnapshotKey: true]

        // Act
        let completion = WatchMessage.completion(from: payload)

        // Assert
        XCTAssertNil(completion)
    }
}
