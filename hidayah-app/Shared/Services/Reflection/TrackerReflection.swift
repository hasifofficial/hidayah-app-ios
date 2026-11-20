//
//  TrackerReflection.swift
//  simple-quran
//

import Foundation
import Observation

/// The tracker facts a reflection may mention. Nothing else about the user
/// is sent to the model.
struct TrackerSnapshot: Equatable, Sendable {
    let completed: Int
    let total: Int
    /// A few of today's unfinished task names, in tracker order.
    let remainingTasks: [String]
    let currentStreak: Int
    let level: Int
    let partOfDay: PartOfDay

    static let maxRemainingTasks = 3

    init(
        completed: Int,
        total: Int,
        remainingTasks: [String],
        currentStreak: Int,
        level: Int,
        partOfDay: PartOfDay
    ) {
        self.completed = completed
        self.total = total
        self.remainingTasks = Array(remainingTasks.prefix(Self.maxRemainingTasks))
        self.currentStreak = currentStreak
        self.level = level
        self.partOfDay = partOfDay
    }
}

enum PartOfDay: String, Sendable {
    case morning
    case afternoon
    case evening
    case night

    static func current(
        at date: Date,
        calendar: Calendar = .current
    ) -> PartOfDay {
        switch calendar.component(.hour, from: date) {
        case 5..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17..<21:
            return .evening
        default:
            return .night
        }
    }
}

/// Writes a short encouragement from today's tracker facts.
protocol TrackerReflectionGenerating: Sendable {
    /// Whether a reflection can be generated on this device right now.
    var isAvailable: Bool { get }

    func reflection(for snapshot: TrackerSnapshot) async throws -> String
}

/// Used where Apple Intelligence isn't available. Home then shows its
/// built-in summary sentence instead.
struct UnavailableReflectionGenerator: TrackerReflectionGenerating {
    struct Unavailable: Error {}

    var isAvailable: Bool { false }

    func reflection(for snapshot: TrackerSnapshot) async throws -> String {
        throw Unavailable()
    }
}

enum TrackerReflection {
    /// Apple's on-device model on iOS 26 and later, otherwise the
    /// unavailable fallback.
    static func makeDefault() -> any TrackerReflectionGenerating {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return FoundationModelsReflectionGenerator()
        }
        #endif
        return UnavailableReflectionGenerator()
    }

    /// Rules for the model. The tracker is about worship, so it must never
    /// produce religious content of its own.
    static let instructions = """
        You write one short, warm encouragement for a Muslim using a daily worship tracker app.
        Use only the facts you are given. Never invent numbers, tasks or events.
        Write one sentence of at most 20 words, in simple English.
        You may use common phrases such as Bismillah, Masha'Allah, Alhamdulillah or In sha Allah.
        Never quote, paraphrase or cite the Quran or hadith, and never give religious rulings or advice.
        Never guilt, shame or pressure the user.
        """

    /// The facts for one reflection, written as plain lines.
    static func prompt(for snapshot: TrackerSnapshot) -> String {
        var lines = [
            "Part of day: \(snapshot.partOfDay.rawValue)",
            "Tasks done today: \(snapshot.completed) of \(snapshot.total)",
            "Current streak: \(snapshot.currentStreak) days",
            "Level: \(snapshot.level)"
        ]

        if !snapshot.remainingTasks.isEmpty {
            lines.append("Some tasks still to do: \(snapshot.remainingTasks.joined(separator: ", "))")
        }

        lines.append("Write the encouragement.")
        return lines.joined(separator: "\n")
    }

    static let maxLength = 180

    /// Trims what the model returned, or nil when it isn't usable.
    static func sanitize(_ text: String) -> String? {
        let trimmed = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"“”"))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty, trimmed.count <= maxLength else { return nil }
        return trimmed
    }
}

/// Holds the reflection shown on Home's tracker card.
@MainActor
@Observable
final class HomeReflectionModel {
    /// The latest reflection for the current tracker facts, or nil while
    /// none is ready, in which case Home shows its built-in sentence.
    private(set) var message: String?

    @ObservationIgnored
    private let generator: any TrackerReflectionGenerating

    @ObservationIgnored
    private let debounce: Duration

    @ObservationIgnored
    private var lastSnapshot: TrackerSnapshot?

    init(
        generator: any TrackerReflectionGenerating,
        debounce: Duration = .milliseconds(600)
    ) {
        self.generator = generator
        self.debounce = debounce
    }

    /// Generates a reflection for `snapshot` unless the facts haven't
    /// changed. Run it from a task tied to the snapshot so a newer one
    /// cancels it.
    func generate(for snapshot: TrackerSnapshot) async {
        guard generator.isAvailable, snapshot != lastSnapshot else { return }

        // The old message talks about old numbers, so drop it straight away.
        message = nil

        if debounce > .zero {
            try? await Task.sleep(for: debounce)
        }
        guard !Task.isCancelled else { return }

        do {
            let text = try await generator.reflection(for: snapshot)
            guard !Task.isCancelled else { return }
            message = TrackerReflection.sanitize(text)
            lastSnapshot = snapshot
        } catch {
            message = nil
        }
    }
}
