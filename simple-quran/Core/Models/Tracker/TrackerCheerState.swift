//
//  TrackerCheerState.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
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
