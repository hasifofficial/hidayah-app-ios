//
//  HomeShortcutsViewModelTests.swift
//  hidayah-app-tests
//

import XCTest
@testable import hidayah_app

@MainActor
final class HomeShortcutsViewModelTests: XCTestCase {
    private var store: UserDefaults!

    override func setUp() {
        super.setUp()
        store = UserDefaults(suiteName: "HomeShortcutsViewModelTests.\(UUID())")
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    func test_init_should_startWithDefaults() {
        // Arrange
        // A fresh store with nothing saved.

        // Act
        let vm = HomeShortcutsViewModel(store: store)

        // Assert
        XCTAssertEqual(vm.selected, [.quran, .mathurat, .tasbih])
        XCTAssertEqual(vm.available, [.qibla, .rakaat, .qada, .tracker])
        XCTAssertFalse(vm.canAdd)
        XCTAssertTrue(vm.isDefault)
    }

    func test_removeAndAdd_should_saveEachChange() {
        // Arrange
        let vm = HomeShortcutsViewModel(store: store)

        // Act
        vm.remove(.mathurat)
        vm.add(.tracker)

        // Assert
        XCTAssertEqual(vm.selected, [.quran, .tasbih, .tracker])
        XCTAssertEqual(HomeShortcuts.load(from: store), [.quran, .tasbih, .tracker])
        XCTAssertFalse(vm.isDefault)
    }

    func test_add_should_doNothing_when_full() {
        // Arrange
        let vm = HomeShortcutsViewModel(store: store)

        // Act
        vm.add(.tracker)

        // Assert
        XCTAssertEqual(vm.selected, [.quran, .mathurat, .tasbih])
    }

    func test_remove_should_keepLastShortcut() {
        // Arrange
        HomeShortcuts.save([.tasbih], to: store)
        let vm = HomeShortcutsViewModel(store: store)

        // Act
        vm.remove(.tasbih)
        vm.remove(atOffsets: IndexSet(integer: 0))

        // Assert
        XCTAssertEqual(vm.selected, [.tasbih])
        XCTAssertFalse(vm.canRemove)
    }

    func test_move_should_reorderAndSave() {
        // Arrange
        let vm = HomeShortcutsViewModel(store: store)

        // Act
        vm.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        // Assert
        XCTAssertEqual(vm.selected, [.tasbih, .quran, .mathurat])
        XCTAssertEqual(HomeShortcuts.load(from: store), [.tasbih, .quran, .mathurat])
    }

    func test_resetToDefault_should_restoreDefaults() {
        // Arrange
        HomeShortcuts.save([.tracker], to: store)
        let vm = HomeShortcutsViewModel(store: store)

        // Act
        vm.resetToDefault()

        // Assert
        XCTAssertEqual(vm.selected, [.quran, .mathurat, .tasbih])
        XCTAssertEqual(HomeShortcuts.load(from: store), [.quran, .mathurat, .tasbih])
    }
}
