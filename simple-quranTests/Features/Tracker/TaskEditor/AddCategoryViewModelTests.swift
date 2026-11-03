//
//  AddCategoryViewModelTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

@MainActor
final class AddCategoryViewModelTests: XCTestCase {
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

    func test_init_should_defaultToFolderIconFromIconList() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let vm = AddCategoryViewModel()

        // Assert
        XCTAssertEqual(vm.iconName, "folder")
        XCTAssertEqual(vm.icons.count, 16)
        XCTAssertEqual(Set(vm.icons).count, vm.icons.count)
        XCTAssertTrue(vm.icons.contains(vm.iconName))
        XCTAssertFalse(vm.canSave)
    }

    func test_canSave_should_requireNonBlankCategoryName() {
        // Arrange
        let vm = AddCategoryViewModel()

        // Act
        vm.categoryName = " \t "
        let blank = vm.canSave
        vm.categoryName = "Night"
        let valid = vm.canSave

        // Assert
        XCTAssertFalse(blank)
        XCTAssertTrue(valid)
    }

    func test_saveCategory_should_addTrimmedCategoryWithIconAndPersistIt() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        let vm = AddCategoryViewModel()
        vm.categoryName = "  Night routine "
        vm.iconName = "moon.stars"

        // Act
        let saved = vm.save(using: taskManager)

        // Assert
        XCTAssertTrue(saved)
        XCTAssertEqual(taskManager.customCategories.map(\.name), ["Night routine"])
        XCTAssertEqual(taskManager.customCategories.first?.icon, "moon.stars")
        let reloaded = VMFixtures.makeTaskManager(store: store)
        XCTAssertEqual(reloaded.customCategories.map(\.name), ["Night routine"])
    }

    func test_saveCategory_should_rejectBlankName() {
        // Arrange
        let taskManager = VMFixtures.makeTaskManager(store: store)
        let vm = AddCategoryViewModel()
        vm.categoryName = "   "

        // Act
        let saved = vm.save(using: taskManager)

        // Assert
        XCTAssertFalse(saved)
        XCTAssertTrue(taskManager.customCategories.isEmpty)
    }
}
