//
//  TrackerDayRecord.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

enum TrackerDayKey {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }

    static func key(for date: Date, calendar: Calendar = TrackerDayKey.calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 1970,
            components.month ?? 1,
            components.day ?? 1
        )
    }

    static func date(
        from key: String,
        calendar: Calendar = TrackerDayKey.calendar
    ) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return calendar.date(from: components)
    }

    static func today(
        now: Date = Date(),
        calendar: Calendar = TrackerDayKey.calendar
    ) -> String {
        key(for: now, calendar: calendar)
    }
}

struct TrackerTaskSnapshot: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let categoryID: String
    let categoryName: String
    let categoryIcon: String
    let isCompleted: Bool

    init(task: TaskDetails) {
        id = task.id
        name = task.name
        categoryID = task.category.id
        categoryName = task.category.name
        categoryIcon = task.category.icon
        isCompleted = task.isCompleted
    }
}

struct TrackerDayRecord: Codable, Identifiable, Equatable {
    let dayKey: String
    let tasks: [TrackerTaskSnapshot]
    let completedCount: Int
    let totalCount: Int
    let points: Int

    var id: String { dayKey }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var isPerfectDay: Bool {
        totalCount > 0 && completedCount == totalCount
    }

    init(dayKey: String, tasks: [TrackerTaskSnapshot]) {
        self.dayKey = dayKey
        self.tasks = tasks
        totalCount = tasks.count
        completedCount = tasks.filter(\.isCompleted).count
        points = TrackerScoring.points(
            completedCount: completedCount,
            totalCount: totalCount
        )
    }

    init(
        dayKey: String,
        completedCount: Int,
        totalCount: Int,
        points: Int
    ) {
        self.dayKey = dayKey
        self.tasks = []
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.points = points
    }
}

enum TrackerScoring {
    static let pointsPerTask = 10
    static let perfectDayBonus = 50

    static func points(completedCount: Int, totalCount: Int) -> Int {
        guard completedCount > 0 else { return 0 }

        var points = completedCount * pointsPerTask
        if totalCount > 0 && completedCount == totalCount {
            points += perfectDayBonus
        }
        return points
    }
}
