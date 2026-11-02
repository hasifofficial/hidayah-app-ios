//
//  TrackerAchievementsViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation
import Observation

@Observable
final class TrackerAchievementsViewModel {
    private let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager
    }

    var stats: TrackerStats {
        taskManager.stats
    }

    var shareSummary: String {
        let summary = String(
            format: NSLocalizedString(
                "tracker_share_achievements_format",
                comment: ""
            ),
            stats.level,
            stats.totalPoints,
            stats.unlockedBadges.count,
            TrackerBadge.allCases.count
        )
        return summary + "\n\n" + shareFooter
    }

    func shareText(for badge: TrackerBadge) -> String {
        let text = String(
            format: NSLocalizedString(
                "tracker_share_badge_format",
                comment: ""
            ),
            badge.title,
            badge.detail
        )
        return text + "\n\n" + shareFooter
    }

    private var shareFooter: String {
        NSLocalizedString("tracker_share_footer", comment: "")
    }
}
