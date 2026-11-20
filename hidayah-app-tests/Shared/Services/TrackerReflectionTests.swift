//
//  TrackerReflectionTests.swift
//  simple-quranTests
//

import XCTest
@testable import simple_quran

private final class FakeReflectionGenerator: TrackerReflectionGenerating, @unchecked Sendable {
    var isAvailable = true
    var result: Result<String, Error> = .success("Masha'Allah, keep going!")
    private(set) var receivedSnapshots: [TrackerSnapshot] = []

    func reflection(for snapshot: TrackerSnapshot) async throws -> String {
        receivedSnapshots.append(snapshot)
        return try result.get()
    }
}

private struct FakeError: Error {}

@MainActor
final class HomeReflectionModelTests: XCTestCase {
    private var generator: FakeReflectionGenerator!
    private var sut: HomeReflectionModel!

    private let snapshot = TrackerSnapshot(
        completed: 3,
        total: 8,
        remainingTasks: ["Read Al-Mulk", "Dhikr", "Sadaqah", "Tahajjud"],
        currentStreak: 4,
        level: 2,
        partOfDay: .evening
    )

    override func setUp() async throws {
        try await super.setUp()
        generator = FakeReflectionGenerator()
        sut = HomeReflectionModel(generator: generator, debounce: .zero)
    }

    func test_generate_should_showMessage_when_generatorSucceeds() async {
        // Arrange
        generator.result = .success("  Masha'Allah, 4 days strong!  ")

        // Act
        await sut.generate(for: snapshot)

        // Assert
        XCTAssertEqual(sut.message, "Masha'Allah, 4 days strong!")
        XCTAssertEqual(generator.receivedSnapshots, [snapshot])
    }

    func test_generate_should_skipModel_when_unavailable() async {
        // Arrange
        generator.isAvailable = false

        // Act
        await sut.generate(for: snapshot)

        // Assert
        XCTAssertNil(sut.message)
        XCTAssertTrue(generator.receivedSnapshots.isEmpty)
    }

    func test_generate_should_fallBack_when_generatorFails() async {
        // Arrange
        generator.result = .failure(FakeError())

        // Act
        await sut.generate(for: snapshot)

        // Assert
        XCTAssertNil(sut.message)
    }

    func test_generate_should_notRegenerate_when_factsUnchanged() async {
        // Arrange
        await sut.generate(for: snapshot)

        // Act
        await sut.generate(for: snapshot)

        // Assert
        XCTAssertEqual(generator.receivedSnapshots.count, 1)
        XCTAssertNotNil(sut.message)
    }

    func test_generate_should_dropOldMessage_when_factsChangeAndGenerationFails() async {
        // Arrange
        await sut.generate(for: snapshot)
        generator.result = .failure(FakeError())
        let newer = TrackerSnapshot(
            completed: 4,
            total: 8,
            remainingTasks: [],
            currentStreak: 4,
            level: 2,
            partOfDay: .evening
        )

        // Act
        await sut.generate(for: newer)

        // Assert
        XCTAssertNil(sut.message)
    }

    func test_generate_should_rejectEmptyOrOverlongText() async {
        // Arrange
        generator.result = .success(String(repeating: "a", count: TrackerReflection.maxLength + 1))

        // Act
        await sut.generate(for: snapshot)

        // Assert
        XCTAssertNil(sut.message)
    }
}

final class TrackerReflectionTests: XCTestCase {
    func test_snapshot_should_keepAtMostThreeRemainingTasks() {
        // Arrange
        let names = ["A", "B", "C", "D", "E"]

        // Act
        let snapshot = TrackerSnapshot(
            completed: 0,
            total: 5,
            remainingTasks: names,
            currentStreak: 0,
            level: 1,
            partOfDay: .morning
        )

        // Assert
        XCTAssertEqual(snapshot.remainingTasks, ["A", "B", "C"])
    }

    func test_prompt_should_listOnlyTrackerFacts() {
        // Arrange
        let snapshot = TrackerSnapshot(
            completed: 5,
            total: 8,
            remainingTasks: ["Read Al-Mulk"],
            currentStreak: 3,
            level: 2,
            partOfDay: .night
        )

        // Act
        let prompt = TrackerReflection.prompt(for: snapshot)

        // Assert
        XCTAssertEqual(
            prompt,
            """
            Part of day: night
            Tasks done today: 5 of 8
            Current streak: 3 days
            Level: 2
            Some tasks still to do: Read Al-Mulk
            Write the encouragement.
            """
        )
    }

    func test_sanitize_should_stripQuotesAndWhitespace() {
        // Arrange
        let raw = "  “Alhamdulillah, all done!”\n"

        // Act
        let text = TrackerReflection.sanitize(raw)

        // Assert
        XCTAssertEqual(text, "Alhamdulillah, all done!")
    }

    func test_instructions_should_forbidReligiousContent() {
        // Arrange
        let instructions = TrackerReflection.instructions

        // Act
        let forbidsQuran = instructions.contains("Never quote, paraphrase or cite the Quran or hadith")

        // Assert
        XCTAssertTrue(forbidsQuran)
    }

    func test_partOfDay_should_followTheHour() {
        // Arrange
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        func at(_ hour: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: hour))!
        }

        // Act
        let parts = [4, 5, 12, 17, 21].map { PartOfDay.current(at: at($0), calendar: calendar) }

        // Assert
        XCTAssertEqual(parts, [.night, .morning, .afternoon, .evening, .night])
    }
}
