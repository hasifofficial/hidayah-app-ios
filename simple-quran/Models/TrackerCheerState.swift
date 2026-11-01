//
//  TrackerCheerState.swift
//  simple-quran
//

import Foundation

struct TrackerCheerState: Codable {
    var dayKey: String
    var sentMilestones: Set<Int>

    init(
        dayKey: String = TrackerDayKey.today(),
        sentMilestones: Set<Int> = []
    ) {
        self.dayKey = dayKey
        self.sentMilestones = sentMilestones
    }
}
