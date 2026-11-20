//
//  AddTaskViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class AddTaskViewModelTests: XCTestCase {
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

    func test_configure_should_loadCategoriesAndSelectFirst() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        taskManager.addCustomCategory(name: "Study", icon: "book")
        let vm = AddTaskViewModel()

        // Act
        vm.configure(with: taskManager)

        // Assert
        XCTAssertEqual(vm.categories.map(\.id), taskManager.allCategories().map(\.id))
        XCTAssertEqual(vm.categories.last?.name, "Study")
        XCTAssertEqual(vm.selectedCategory, .default(.morning))
    }

    func test_configure_should_keepExistingSelection() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        let vm = AddTaskViewModel()
        vm.selectedCategory = .default(.isha)

        // Act
        vm.configure(with: taskManager)

        // Assert
        XCTAssertEqual(vm.selectedCategory, .default(.isha))
    }

    func test_canSave_should_requireNonBlankNameAndCategory() {
        // Arrange
        let vm = AddTaskViewModel()

        // Act
        vm.taskName = "Read Quran"
        let withoutCategory = vm.canSave
        vm.selectedCategory = .default(.fajr)
        vm.taskName = "   \n"
        let blankName = vm.canSave
        vm.taskName = " Read Quran "
        let valid = vm.canSave

        // Assert
        XCTAssertFalse(withoutCategory)
        XCTAssertFalse(blankName)
        XCTAssertTrue(valid)
    }

    func test_saveTask_should_addTrimmedTaskAndPersistIt() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        let initialCount = taskManager.tasks.count
        let vm = AddTaskViewModel()
        vm.configure(with: taskManager)
        vm.selectedCategory = .default(.dhuha)
        vm.taskName = "  Read Surah Al-Kahf  "

        // Act
        let saved = vm.save(using: taskManager)

        // Assert
        XCTAssertTrue(saved)
        XCTAssertEqual(taskManager.tasks.count, initialCount + 1)
        XCTAssertEqual(taskManager.tasks.last?.name, "Read Surah Al-Kahf")
        XCTAssertEqual(taskManager.tasks.last?.category, .default(.dhuha))
        let reloaded = VMFixtures.makeTaskManager(store: store)
        XCTAssertEqual(reloaded.tasks.last?.name, "Read Surah Al-Kahf")
    }

    func test_saveTask_should_rejectInvalidInput() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        let initialCount = taskManager.tasks.count
        let vm = AddTaskViewModel()
        vm.configure(with: taskManager)
        vm.taskName = "  "

        // Act
        let saved = vm.save(using: taskManager)

        // Assert
        XCTAssertFalse(saved)
        XCTAssertEqual(taskManager.tasks.count, initialCount)
    }
}
