//
//  MathuratFixtures.swift
//  simple-quranTests
//

import Foundation
@testable import simple_quran

/// A loader serving in-memory entries, so tests don't depend on the bundled
/// text. Used only from the main actor.
final class FakeMathuratLoader: MathuratLoading, @unchecked Sendable {
    var entries: [MathuratEntry]
    var error: Error?
    private(set) var requests: [MathuratTime] = []

    init(entries: [MathuratEntry] = MathuratFixtures.entries()) {
        self.entries = entries
    }

    func entries(for time: MathuratTime) throws -> [MathuratEntry] {
        requests.append(time)
        if let error {
            throw error
        }
        return entries.filter { $0.reading.includes(time) }
    }
}

enum MathuratFixtures {
    static func entry(
        id: Int,
        title: String? = nil,
        repeatCount: Int = 1,
        reading: MathuratEntry.Reading = .both
    ) -> MathuratEntry {
        MathuratEntry(
            id: id,
            title: title,
            repeatCount: repeatCount,
            reading: reading,
            arabic: "أَعُوذُ بِاللَّهِ \(id)",
            translation: "Aku berlindung \(id)"
        )
    }

    /// Two entries for both sessions, plus one morning-only and one
    /// evening-only du'a.
    static func entries() -> [MathuratEntry] {
        [
            entry(id: 1),
            entry(id: 2, title: "Al Fatihah (1-7)"),
            entry(id: 13, repeatCount: 3, reading: .morning),
            entry(id: 14, repeatCount: 3, reading: .evening)
        ]
    }

    /// 10:00 or 16:00 on a fixed day in the tracker calendar.
    static func clock(morning: Bool) -> TestClock {
        TestClock(TestClock.date(year: 2026, month: 11, day: 4, hour: morning ? 10 : 16))
    }
}
