//
//  MathuratLibraryTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

final class MathuratLibraryTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MathuratLibraryTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
        try super.tearDownWithError()
    }

    // MARK: Failures

    func test_entries_should_throwMissingResource_when_bundleIsMissing() {
        // Arrange
        let loader = BundleMathuratLoader(directory: nil)

        // Act & Assert
        XCTAssertThrowsError(try loader.entries(for: .morning)) { error in
            XCTAssertEqual(error as? MathuratLoadError, .missingResource)
        }
    }

    func test_entries_should_throwMissingResource_when_fileIsMissing() {
        // Arrange
        let loader = BundleMathuratLoader(directory: directory)

        // Act & Assert
        XCTAssertThrowsError(try loader.entries(for: .morning)) { error in
            XCTAssertEqual(error as? MathuratLoadError, .missingResource)
        }
    }

    func test_entries_should_throwCorrupt_when_jsonIsInvalid() throws {
        // Arrange
        try Data("{ not json".utf8).write(to: directory.appendingPathComponent("sughra.json"))
        let loader = BundleMathuratLoader(directory: directory)

        // Act & Assert
        XCTAssertThrowsError(try loader.entries(for: .morning)) { error in
            XCTAssertEqual(error as? MathuratLoadError, .corrupt)
        }
    }

    func test_entries_should_decodeFileFromDirectory() throws {
        // Arrange
        let json = #"{"entries":[{"id":1,"order":1,"title":"","repeat":3,"time":"both","arabic":"ا","translation":"t"}]}"#
        try Data(json.utf8).write(to: directory.appendingPathComponent("sughra.json"))
        let loader = BundleMathuratLoader(directory: directory)

        // Act
        let entries = try loader.entries(for: .evening)

        // Assert
        XCTAssertEqual(entries.map(\.id), [1])
        XCTAssertEqual(entries.first?.repeatCount, 3)
    }

    // MARK: Bundled content
    //
    // These guard against accidental edits to the religious text. They do
    // not prove it is correct; that needs a review against a printed
    // Al-Ma'thurat.

    func test_bundledSughra_should_haveExpectedEntriesPerSession() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let morning = try loader.entries(for: .morning)
        let evening = try loader.entries(for: .evening)

        // Assert
        XCTAssertEqual(morning.count, 34)
        XCTAssertEqual(evening.count, 35)
        XCTAssertEqual(Set(morning.map(\.id)).union(evening.map(\.id)).count, 39)
    }

    func test_bundledSughra_should_startWithTaawudzAndAlFatihah() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let morning = try loader.entries(for: .morning)

        // Assert
        XCTAssertTrue(morning[0].arabic.hasPrefix("اَعُوذُ بِٱللهِ"))
        XCTAssertEqual(morning[0].title, "Isti'adah (Seeking Refuge)")
        XCTAssertEqual(morning[1].title, "Al-Faatiha (1-7)")
    }

    func test_bundledSughra_should_useMorningAndEveningWordingInEachSession() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let morningOnly = try loader.entries(for: .morning).filter { $0.reading == .morning }
        let eveningOnly = try loader.entries(for: .evening).filter { $0.reading == .evening }

        // Assert
        XCTAssertEqual(morningOnly.count, 4)
        XCTAssertEqual(eveningOnly.count, 5)
        XCTAssertTrue(morningOnly.allSatisfy { $0.translation.contains("Pagi") || $0.arabic.contains("أَصْبَح") })
        XCTAssertTrue(eveningOnly.contains { $0.arabic.contains("أَمْسَيْنَا") })
    }

    func test_bundledSughra_should_titleEveryEntry() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let untitled = try MathuratTime.allCases
            .flatMap { try loader.entries(for: $0) }
            .filter { $0.title == nil }

        // Assert
        XCTAssertTrue(untitled.isEmpty, "\(untitled.map(\.id))")
    }

    func test_bundledSughra_should_onlyUseKnownRepeatCounts() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let repeats = try Set(MathuratTime.allCases.flatMap {
            try loader.entries(for: $0).map(\.repeatCount)
        })

        // Assert
        XCTAssertEqual(repeats, [1, 3])
    }

    func test_bundledSughra_should_haveArabicAndTranslationForEveryEntry() throws {
        // Arrange
        let loader = BundleMathuratLoader()

        // Act
        let entries = try MathuratTime.allCases.flatMap { try loader.entries(for: $0) }
        let incomplete = entries.filter {
            $0.arabic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || $0.translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        // Assert
        XCTAssertTrue(incomplete.isEmpty, "\(incomplete.map(\.id))")
    }
}
