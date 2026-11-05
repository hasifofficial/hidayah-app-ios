//
//  TrackerHistoryEngine.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

struct TrackerHistoryEngine {
    let calendar: Calendar

    init(calendar: Calendar = TrackerDayKey.calendar) {
        self.calendar = calendar
    }

    func makeRecord(
        for tasks: [TaskDetails],
        on dayKey: String
    ) -> TrackerDayRecord? {
        let snapshots = tasks.map(TrackerTaskSnapshot.init(task:))
        let completed = snapshots.filter(\.isCompleted).count
        guard completed > 0 else { return nil }
        return TrackerDayRecord(dayKey: dayKey, tasks: snapshots)
    }

    func upsert(
        _ record: TrackerDayRecord?,
        for dayKey: String,
        in history: inout [TrackerDayRecord]
    ) {
        history.removeAll { $0.dayKey == dayKey }
        if let record {
            history.append(record)
            history.sort { $0.dayKey < $1.dayKey }
        }
    }

    @discardableResult
    func rollover(
        activeDayKey: String?,
        tasks: inout [TaskDetails],
        history: inout [TrackerDayRecord],
        now: Date = Date()
    ) -> String {
        let todayKey = TrackerDayKey.key(for: now, calendar: calendar)
        guard let activeDayKey, activeDayKey != todayKey else {
            return todayKey
        }

        if let record = makeRecord(for: tasks, on: activeDayKey) {
            upsert(record, for: activeDayKey, in: &history)
        }

        for index in tasks.indices {
            tasks[index].isCompleted = false
        }

        return todayKey
    }

    func stats(
        for history: [TrackerDayRecord],
        now: Date = Date()
    ) -> TrackerStats {
        TrackerStats(
            records: history,
            now: now,
            calendar: calendar
        )
    }
}
