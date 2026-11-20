//
//  WatchTrackerStateTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

final class WatchTrackerStateTests: XCTestCase {
    private let fajr = makeTask("Fajr prayer")
    private let dhuha = makeTask("Dhuha prayer", category: .default(.dhuha), isCompleted: true)

    private let noon = TestClock.date(year: 2026, month: 3, day: 10)
    private let nextDayStart = TestClock.date(year: 2026, month: 3, day: 11, hour: 0)
    private let nextDayEnd = TestClock.date(year: 2026, month: 3, day: 12, hour: 0)

    private func makeSnapshot(
        dayKey: String = "2026-03-10",
        tasks: [TaskDetails]? = nil,
        generatedAt: Date? = nil
    ) -> WatchTrackerSnapshot {
        WatchTrackerSnapshot(
            dayKey: dayKey,
            tasks: tasks ?? [fajr, dhuha],
            currentStreak: 4,
            nextDayStart: nextDayStart,
            nextDayKey: "2026-03-11",
            nextDayEnd: nextDayEnd,
            generatedAt: generatedAt
        )
    }

    // MARK: - Reading

    func test_tasks_should_beEmptyBeforeFirstSnapshot() {
        // Arrange
        let sut = WatchTrackerState()

        // Act
        let tasks = sut.tasks(now: noon)

        // Assert
        XCTAssertTrue(tasks.isEmpty)
        XCTAssertNil(sut.dayKey(now: noon))
        XCTAssertFalse(sut.isStale(now: noon))
    }

    func test_tasks_should_showSnapshotDuringItsDay() {
        // Arrange
        let sut = WatchTrackerState(snapshot: makeSnapshot())

        // Act
        let tasks = sut.tasks(now: noon)

        // Assert
        XCTAssertEqual(tasks.map(\.isCompleted), [false, true])
        XCTAssertEqual(sut.dayKey(now: noon), "2026-03-10")
    }

    func test_tasks_should_clearCompletionsOnceNextDayStarts() {
        // Arrange
        let sut = WatchTrackerState(snapshot: makeSnapshot())
        let morning = TestClock.date(year: 2026, month: 3, day: 11, hour: 8)

        // Act
        let tasks = sut.tasks(now: morning)

        // Assert
        XCTAssertEqual(tasks.map(\.isCompleted), [false, false])
        XCTAssertEqual(sut.dayKey(now: morning), "2026-03-11")
        XCTAssertTrue(sut.hasRolledOver(now: morning))
    }

    func test_isStale_should_beTrueAfterTheFollowingDayEnds() {
        // Arrange
        let sut = WatchTrackerState(snapshot: makeSnapshot())
        let later = TestClock.date(year: 2026, month: 3, day: 12, hour: 9)

        // Act
        let isStale = sut.isStale(now: later)

        // Assert
        XCTAssertTrue(isStale)
        XCTAssertNil(sut.dayKey(now: later))
    }

    // MARK: - Tapping

    func test_setCompletion_should_showTapAndReturnRequest() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())

        // Act
        let request = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Assert
        XCTAssertEqual(
            request,
            WatchTaskCompletion(taskID: fajr.id, isCompleted: true, dayKey: "2026-03-10")
        )
        XCTAssertEqual(sut.tasks(now: noon).map(\.isCompleted), [true, true])
        XCTAssertEqual(sut.progress(now: noon).completed, 2)
    }

    func test_setCompletion_should_useNextDayKeyAfterRollover() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        let morning = TestClock.date(year: 2026, month: 3, day: 11, hour: 8)

        // Act
        let request = sut.setCompletion(taskID: dhuha.id, isCompleted: true, now: morning)

        // Assert
        XCTAssertEqual(request?.dayKey, "2026-03-11")
        XCTAssertEqual(sut.tasks(now: morning).map(\.isCompleted), [false, true])
    }

    func test_setCompletion_should_refuseWhenStale() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        let later = TestClock.date(year: 2026, month: 3, day: 12, hour: 9)

        // Act
        let request = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: later)

        // Assert
        XCTAssertNil(request)
        XCTAssertTrue(sut.pending.isEmpty)
    }

    func test_setCompletion_should_refuseUnknownTask() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())

        // Act
        let request = sut.setCompletion(taskID: UUID(), isCompleted: true, now: noon)

        // Assert
        XCTAssertNil(request)
    }

    // MARK: - Applying snapshots

    func test_apply_should_keepUnconfirmedTapOverOlderSnapshot() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        sut.apply(makeSnapshot())

        // Assert
        XCTAssertEqual(sut.pending.mapValues(\.isCompleted), [fajr.id: true])
        XCTAssertTrue(sut.tasks(now: noon)[0].isCompleted)
    }

    func test_apply_should_confirmTapTheIPhoneReflects() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)
        var confirmed = fajr
        confirmed.isCompleted = true

        // Act
        sut.apply(makeSnapshot(tasks: [confirmed, dhuha]))

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
        XCTAssertNil(sut.pendingDayKey)
        XCTAssertTrue(sut.tasks(now: noon)[0].isCompleted)
    }

    func test_apply_should_dropTapForDeletedTask() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        sut.apply(makeSnapshot(tasks: [dhuha]))

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
    }

    func test_apply_should_dropTapsFromAPastDay() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        sut.apply(makeSnapshot(dayKey: "2026-03-11"))

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
        XCTAssertNil(sut.pendingDayKey)
    }

    func test_apply_should_keepTapsWhenWatchRolledOverFirst() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        let morning = TestClock.date(year: 2026, month: 3, day: 11, hour: 8)
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: morning)

        // Act
        sut.apply(makeSnapshot())

        // Assert
        XCTAssertEqual(sut.pending.mapValues(\.isCompleted), [fajr.id: true])
        XCTAssertEqual(sut.pendingDayKey, "2026-03-11")
    }

    func test_apply_should_settleTapTheIPhoneSawButDidNotApply() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)
        let afterTap = noon.addingTimeInterval(2)

        // Act
        sut.apply(makeSnapshot(generatedAt: afterTap))

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
        XCTAssertNil(sut.pendingDayKey)
        XCTAssertFalse(sut.tasks(now: afterTap)[0].isCompleted)
    }

    func test_apply_should_keepTapSnapshotWasMadeBefore() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        sut.apply(makeSnapshot(generatedAt: noon.addingTimeInterval(-5)))

        // Assert
        XCTAssertEqual(sut.pending.mapValues(\.isCompleted), [fajr.id: true])
        XCTAssertTrue(sut.tasks(now: noon)[0].isCompleted)
    }

    func test_apply_should_settleNextDayTapOnceIPhoneSawIt() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        let morning = TestClock.date(year: 2026, month: 3, day: 11, hour: 8)
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: morning)

        // Act
        sut.apply(makeSnapshot(generatedAt: morning.addingTimeInterval(1)))

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
    }

    func test_settle_should_dropTapAndShowReply() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)
        _ = sut.setCompletion(taskID: dhuha.id, isCompleted: false, now: noon)
        var confirmed = fajr
        confirmed.isCompleted = true

        // Act
        sut.settle(taskID: fajr.id, with: makeSnapshot(tasks: [confirmed, dhuha]))

        // Assert
        XCTAssertNil(sut.pending[fajr.id])
        XCTAssertEqual(sut.pending.mapValues(\.isCompleted), [dhuha.id: false])
        XCTAssertEqual(sut.tasks(now: noon).map(\.isCompleted), [true, false])
    }

    func test_settle_should_dropTapWithoutReplySnapshot() {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        sut.settle(taskID: fajr.id, with: nil)

        // Assert
        XCTAssertTrue(sut.pending.isEmpty)
        XCTAssertNil(sut.pendingDayKey)
        XCTAssertFalse(sut.tasks(now: noon)[0].isCompleted)
    }

    func test_hasSameContent_should_ignoreWhenSnapshotWasMade() {
        // Arrange
        let first = makeSnapshot(generatedAt: noon)
        let later = makeSnapshot(generatedAt: noon.addingTimeInterval(60))

        // Act
        let same = later.hasSameContent(as: first)

        // Assert
        XCTAssertTrue(same)
        XCTAssertFalse(later.hasSameContent(as: nil))
        XCTAssertFalse(makeSnapshot(dayKey: "2026-03-11").hasSameContent(as: first))
    }

    // MARK: - Saving

    func test_state_should_roundTripThroughCoding() throws {
        // Arrange
        var sut = WatchTrackerState(snapshot: makeSnapshot())
        _ = sut.setCompletion(taskID: fajr.id, isCompleted: true, now: noon)

        // Act
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(WatchTrackerState.self, from: data)

        // Assert
        XCTAssertEqual(decoded, sut)
    }
}
