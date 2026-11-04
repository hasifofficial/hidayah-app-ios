//
//  StorageTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class StorageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    override func tearDown() {
        resetStorage()
        super.tearDown()
    }

    func test_isRunningUnitTests_should_beTrueUnderXCTest() {
        // Arrange
        // Nothing to arrange beyond the clean state from setUp.

        // Act
        let isRunningUnitTests = AppEnvironment.isRunningUnitTests

        // Assert
        XCTAssertTrue(isRunningUnitTests)
    }

    func test_userDefaults_should_useIsolatedTestSuite() {
        // Arrange
        let suite = UserDefaults(suiteName: "com.hasifofficial.simple-quran.tests")

        // Act
        Storage.save(.quranArabicFontSize, 31)

        // Assert
        XCTAssertNotNil(Storage.userDefaults)
        XCTAssertEqual(suite?.integer(forKey: "quranArabicFontSize"), 31)
    }

    func test_save_should_storeValueForKey() {
        // Arrange
        let key = Storage.StorageKey.selectedRecitation

        // Act
        Storage.save(key, "ar.alafasy")

        // Assert
        XCTAssertEqual(Storage.load(key: key) as? String, "ar.alafasy")
    }

    func test_load_should_returnNilForMissingKey() {
        // Arrange
        let key = Storage.StorageKey.selectedTranslation

        // Act
        let value = Storage.load(key: key)

        // Assert
        XCTAssertNil(value)
    }

    func test_delete_should_removeStoredValue() {
        // Arrange
        Storage.save(.allowKahfReminder, false)

        // Act
        Storage.delete(.allowKahfReminder)

        // Assert
        XCTAssertNil(Storage.load(key: .allowKahfReminder))
    }

    func test_loadObject_should_decodeStoredJSON() throws {
        // Arrange
        let state = TrackerCheerState(dayKey: "2026-03-10", sentMilestones: [25])
        Storage.save(.trackerCheerState, try JSONEncoder().encode(state))

        // Act
        let loaded: TrackerCheerState? = Storage.loadObject(key: .trackerCheerState)

        // Assert
        XCTAssertEqual(loaded?.dayKey, "2026-03-10")
        XCTAssertEqual(loaded?.sentMilestones, [25])
    }

    func test_loadObject_should_returnNilForUndecodableData() {
        // Arrange
        Storage.save(.trackerCheerState, Data("not json".utf8))

        // Act
        let loaded: TrackerCheerState? = Storage.loadObject(key: .trackerCheerState)

        // Assert
        XCTAssertNil(loaded)
    }

    func test_loadObject_should_returnNilForNonDataValue() {
        // Arrange
        Storage.save(.trackerCheerState, "text")

        // Act
        let loaded: TrackerCheerState? = Storage.loadObject(key: .trackerCheerState)

        // Assert
        XCTAssertNil(loaded)
    }

    func test_storageKeys_should_useCaseNameAsRawValue() {
        // Arrange
        let keys = Storage.StorageKey.allCases

        // Act
        let rawValues = keys.map(\.rawValue)

        // Assert
        XCTAssertEqual(keys.count, 13)
        XCTAssertTrue(rawValues.contains("widgetContext"))
        XCTAssertTrue(rawValues.contains("hasMigratedToSwiftData"))
    }
}
