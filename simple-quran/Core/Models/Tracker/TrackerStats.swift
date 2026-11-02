//
//  TrackerStats.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation

struct TrackerStats {
    static let levelThresholds = [
        0,
        100,
        250,
        500,
        900,
        1_400,
        2_000,
        2_800,
        3_800,
        5_000
    ]

    let totalPoints: Int
    let level: Int
    let levelStartPoints: Int
    let nextLevelPoints: Int?
    let currentStreak: Int
    let longestStreak: Int
    let perfectDays: Int
    let totalCompletedTasks: Int
    let unlockedBadges: Set<TrackerBadge>

    init(
        records: [TrackerDayRecord],
        now: Date = Date(),
        calendar: Calendar = TrackerDayKey.calendar
    ) {
        var latestRecords: [String: TrackerDayRecord] = [:]
        for record in records {
            latestRecords[record.dayKey] = record
        }

        let allRecords = latestRecords.values.sorted { $0.dayKey < $1.dayKey }
        let activeRecords = allRecords.filter { $0.completedCount > 0 }

        totalPoints = allRecords.reduce(0) { $0 + $1.points }
        totalCompletedTasks = allRecords.reduce(0) { $0 + $1.completedCount }
        perfectDays = allRecords.filter(\.isPerfectDay).count

        let activeDays = Set(activeRecords.map(\.dayKey))
        currentStreak = Self.currentStreak(
            activeDays: activeDays,
            now: now,
            calendar: calendar
        )
        longestStreak = Self.longestStreak(
            records: activeRecords,
            calendar: calendar
        )

        var level = 1
        var levelStart = Self.levelThresholds[0]
        var nextLevel: Int?
        for (index, threshold) in Self.levelThresholds.enumerated() where threshold <= totalPoints {
            level = index + 1
            levelStart = threshold
            nextLevel = index + 1 < Self.levelThresholds.count
                ? Self.levelThresholds[index + 1]
                : nil
        }
        self.level = level
        levelStartPoints = levelStart
        nextLevelPoints = nextLevel

        var badges = Set<TrackerBadge>()
        if totalCompletedTasks >= 1 { badges.insert(.firstStep) }
        if longestStreak >= 3 { badges.insert(.streak3) }
        if longestStreak >= 7 { badges.insert(.streak7) }
        if longestStreak >= 30 { badges.insert(.streak30) }
        if perfectDays >= 1 { badges.insert(.perfectDay) }
        if perfectDays >= 10 { badges.insert(.perfectTen) }
        if totalCompletedTasks >= 100 { badges.insert(.century) }
        if totalCompletedTasks >= 1_000 { badges.insert(.devoted) }
        unlockedBadges = badges
    }

    var progressToNextLevel: Double {
        guard let nextLevelPoints else { return 1 }
        let range = nextLevelPoints - levelStartPoints
        guard range > 0 else { return 1 }
        return min(
            1,
            max(0, Double(totalPoints - levelStartPoints) / Double(range))
        )
    }

    func progress(for badge: TrackerBadge) -> Double {
        let current: Int
        switch badge {
        case .firstStep, .century, .devoted:
            current = totalCompletedTasks
        case .streak3, .streak7, .streak30:
            current = longestStreak
        case .perfectDay, .perfectTen:
            current = perfectDays
        }
        return min(1, Double(current) / Double(max(badge.target, 1)))
    }

    func badgeCurrentValue(_ badge: TrackerBadge) -> Int {
        switch badge {
        case .firstStep, .century, .devoted:
            return totalCompletedTasks
        case .streak3, .streak7, .streak30:
            return longestStreak
        case .perfectDay, .perfectTen:
            return perfectDays
        }
    }

    private static func currentStreak(
        activeDays: Set<String>,
        now: Date,
        calendar: Calendar
    ) -> Int {
        guard !activeDays.isEmpty else { return 0 }

        var cursor = TrackerDayKey.today(now: now, calendar: calendar)
        if !activeDays.contains(cursor),
           let yesterday = calendar.date(
               byAdding: .day,
               value: -1,
               to: calendar.startOfDay(for: now)
           ) {
            cursor = TrackerDayKey.key(for: yesterday, calendar: calendar)
        }

        var streak = 0
        while activeDays.contains(cursor) {
            streak += 1
            guard let date = TrackerDayKey.date(from: cursor, calendar: calendar),
                  let previous = calendar.date(
                      byAdding: .day,
                      value: -1,
                      to: date
                  ) else {
                break
            }
            cursor = TrackerDayKey.key(for: previous, calendar: calendar)
        }
        return streak
    }

    private static func longestStreak(
        records: [TrackerDayRecord],
        calendar: Calendar
    ) -> Int {
        var longest = 0
        var current = 0
        var previousDate: Date?

        for record in records {
            guard let date = TrackerDayKey.date(
                from: record.dayKey,
                calendar: calendar
            ) else {
                continue
            }

            if let previousDate,
               calendar.dateComponents(
                   [.day],
                   from: previousDate,
                   to: date
               ).day == 1 {
                current += 1
            } else {
                current = 1
            }

            longest = max(longest, current)
            previousDate = date
        }
        return longest
    }
}
