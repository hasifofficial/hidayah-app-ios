//
//  QuickSurahCatalogTests.swift
//  app-widgetTests
//

import AppIntents
import WidgetKit
import XCTest

@MainActor
final class QuickSurahCatalogTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_all_should_listEverySurahInOrder() {
        // Arrange
        let expectedNumbers = Array(1...114)

        // Act
        let surahs = QuickSurahCatalog.all

        // Assert
        XCTAssertEqual(surahs.map(\.number), expectedNumbers)
        XCTAssertEqual(surahs.map(\.id), expectedNumbers.map(String.init))
        XCTAssertTrue(surahs.allSatisfy { !$0.englishName.isEmpty && !$0.arabicName.isEmpty })
        XCTAssertEqual(surahs.first?.englishName, "Al-Faatiha")
        XCTAssertEqual(surahs.last?.arabicName, "الناس")
    }

    func test_quickAccess_should_listFrequentlyReadSurahsFromCatalog() {
        // Arrange
        let expectedNames = ["Al-Kahf", "As-Sajda", "Yaseen", "Al-Waaqia", "Al-Mulk"]

        // Act
        let surahs = QuickSurahCatalog.quickAccess

        // Assert
        XCTAssertEqual(surahs.map(\.number), [18, 32, 36, 56, 67])
        XCTAssertEqual(surahs.map(\.englishName), expectedNames)
        XCTAssertEqual(surahs.map(\.arabicName), ["الكهف", "السجدة", "يس", "الواقعة", "الملك"])
    }

    func test_displayRepresentation_should_showNameAndNumber() {
        // Arrange
        let surah = QuickSurahCatalog.all[35]

        // Act
        let representation = surah.displayRepresentation

        // Assert
        XCTAssertEqual(String(localized: representation.title), "Yaseen")
        XCTAssertEqual(representation.subtitle.map { String(localized: $0) }, "36")
    }

    func test_typeDisplayRepresentation_should_useSurahTypeKey() {
        // Arrange
        let expectedKey = "widget_surah_type"

        // Act
        let representation = QuickSurahEntity.typeDisplayRepresentation

        // Assert
        XCTAssertEqual(representation.name.key, expectedKey)
    }

    func test_entitiesForIdentifiers_should_returnMatchingSurahs() async throws {
        // Arrange
        let query = QuickSurahEntity.defaultQuery

        // Act
        let surahs = try await query.entities(for: ["2", "114", "999"])

        // Assert
        XCTAssertEqual(surahs.map(\.number), [2, 114])
    }

    func test_entitiesMatching_should_returnAll_when_queryIsBlank() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.entities(matching: "  \n ")

        // Assert
        XCTAssertEqual(surahs.count, 114)
    }

    func test_entitiesMatching_should_matchEnglishNameIgnoringCase() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.entities(matching: " kahf ")

        // Assert
        XCTAssertEqual(surahs.map(\.number), [18])
    }

    func test_entitiesMatching_should_matchArabicName() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.entities(matching: "الملك")

        // Assert
        XCTAssertEqual(surahs.map(\.number), [67])
    }

    func test_entitiesMatching_should_matchExactNumber() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.entities(matching: "36")

        // Assert
        XCTAssertEqual(surahs.map(\.englishName), ["Yaseen"])
    }

    func test_entitiesMatching_should_returnNothing_when_noSurahMatches() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.entities(matching: "zzz")

        // Assert
        XCTAssertTrue(surahs.isEmpty)
    }

    func test_suggestedEntities_should_returnWholeCatalog() async throws {
        // Arrange
        let query = QuickQuickSurahEntityQuery()

        // Act
        let surahs = try await query.suggestedEntities()

        // Assert
        XCTAssertEqual(surahs, QuickSurahCatalog.all)
    }
}

@MainActor
final class QuickSurahCatalogLookupTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetStorage()
    }

    func test_entity_should_returnCatalogSurah_when_numberExists() {
        // Arrange
        let number = 67

        // Act
        let surah = QuickSurahCatalog.entity(number)

        // Assert
        XCTAssertEqual(surah, QuickSurahCatalog.all[66])
        XCTAssertEqual(surah.englishName, "Al-Mulk")
    }

    func test_entity_should_returnPlaceholder_when_numberIsNotASurah() {
        // Arrange
        let number = 115

        // Act
        let surah = QuickSurahCatalog.entity(number)

        // Assert
        XCTAssertEqual(surah.id, "115")
        XCTAssertEqual(surah.number, 115)
        XCTAssertEqual(surah.englishName, "Surah 115")
        XCTAssertEqual(surah.arabicName, "")
    }
}
