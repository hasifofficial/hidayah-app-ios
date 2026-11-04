//
//  MathuratModels.swift
//  simple-quran
//

import Foundation

enum MathuratTime: String, CaseIterable, Sendable {
    case morning
    case evening

    /// Evening starts at 15:00 local time; everything before it, from
    /// midnight, is morning.
    static let eveningStartHour = 15

    static func current(
        at date: Date,
        calendar: Calendar = .current
    ) -> MathuratTime {
        calendar.component(.hour, from: date) < eveningStartHour
            ? .morning
            : .evening
    }

    /// The next moment the time of day changes: 15:00 today, or midnight.
    static func nextChange(
        after date: Date,
        calendar: Calendar = .current
    ) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let eveningStart = calendar.date(
            byAdding: .hour,
            value: eveningStartHour,
            to: startOfDay
        ) ?? date
        if date < eveningStart {
            return eveningStart
        }
        return calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
    }

    var titleKey: String {
        "mathurat_time_\(rawValue)"
    }

    var labelKey: String {
        "mathurat_label_\(rawValue)"
    }

    var icon: String {
        switch self {
        case .morning:
            return "sunrise.fill"
        case .evening:
            return "moon.stars.fill"
        }
    }
}

/// One dhikr, du'a or Quran passage of Al-Mathurat Sughra.
struct MathuratEntry: Identifiable, Equatable, Sendable {
    enum Reading: String, Decodable, Sendable {
        case morning
        case evening
        case both

        func includes(_ time: MathuratTime) -> Bool {
            switch self {
            case .both:
                return true
            case .morning:
                return time == .morning
            case .evening:
                return time == .evening
            }
        }
    }

    /// The source's row id, stable across morning and evening.
    let id: Int
    /// Only Quran passages are named in the source, e.g. "Al Baqarah (255)".
    let title: String?
    let repeatCount: Int
    let reading: Reading
    let arabic: String
    let translation: String
}

// MARK: - Decoding

/// The layout of `Mathurat.bundle/sughra.json`.
struct MathuratFileDTO: Decodable {
    let entries: [MathuratEntryDTO]

    func entries(for time: MathuratTime) -> [MathuratEntry] {
        entries
            .sorted { ($0.order, $0.id) < ($1.order, $1.id) }
            .map(\.entry)
            .filter { $0.reading.includes(time) }
    }
}

struct MathuratEntryDTO: Decodable {
    let id: Int
    let order: Int
    let title: String
    let repeatCount: Int
    let time: MathuratEntry.Reading
    let arabic: String
    let translation: String

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case title
        case repeatCount = "repeat"
        case time
        case arabic
        case translation
    }

    var entry: MathuratEntry {
        MathuratEntry(
            id: id,
            title: title.isEmpty ? nil : title,
            repeatCount: max(repeatCount, 1),
            reading: time,
            arabic: arabic,
            translation: translation
        )
    }
}
