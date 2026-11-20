//
//  TrackerLevelsViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class TrackerLevelsViewModelTests: XCTestCase {
    private var store: HidayahStore!

    override func setUp() {
        super.setUp()
        resetStorage()
        StubURLProtocol.reset()
        store = makeInMemoryStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    /// 80 + 10 + 70 = 160 points: level 2, with First Step and Perfect Day.
    private func makeSeededTaskManager() -> TaskManager {
        store.saveDay(VMFixtures.dayRecord("2026-10-05", completed: 3, total: 3))
        store.saveDay(VMFixtures.dayRecord("2026-10-06", completed: 1, total: 4))
        store.saveDay(VMFixtures.dayRecord("2026-10-20", completed: 2, total: 2))
        return VMFixtures.makeTaskManager(store: store)
    }

    func test_levels_should_listEveryLevelFromCatalog() {
        // Arrange
        let vm = TrackerLevelsViewModel(taskManager: VMFixtures.makeTaskManager(store: store))

        // Act
        let levels = vm.levels

        // Assert
        XCTAssertEqual(levels.map(\.number), Array(1...10))
        XCTAssertEqual(levels.first?.startPoints, 0)
        XCTAssertEqual(levels.first?.endPoints, 99)
        XCTAssertNil(levels.last?.endPoints)
    }

    func test_levelsStats_should_comeFromTaskManager() {
        // Arrange
        let taskManager = makeSeededTaskManager()
        let vm = TrackerLevelsViewModel(taskManager: taskManager)

        // Act
        let stats = vm.stats

        // Assert
        XCTAssertEqual(stats.totalPoints, 160)
        XCTAssertEqual(stats.level, 2)
        XCTAssertEqual(stats.nextLevelPoints, 250)
    }
}
