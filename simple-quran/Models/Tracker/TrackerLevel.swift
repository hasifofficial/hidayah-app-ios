//
//  TrackerLevel.swift
//  simple-quran
//

import Foundation

struct TrackerLevel: Identifiable {
    let number: Int
    let startPoints: Int
    let endPoints: Int?

    var id: Int { number }

    var title: String {
        NSLocalizedString("tracker_level_\(number)_title", comment: "")
    }

    var rangeText: String {
        if let endPoints {
            return String(
                format: NSLocalizedString(
                    "tracker_levels_points_range_format",
                    comment: ""
                ),
                startPoints,
                endPoints
            )
        }
        return String(
            format: NSLocalizedString(
                "tracker_levels_points_plus_format",
                comment: ""
            ),
            startPoints
        )
    }

    var unlockText: String {
        String(
            format: NSLocalizedString(
                "tracker_levels_reach_points_format",
                comment: ""
            ),
            startPoints
        )
    }
}

enum TrackerLevelCatalog {
    static var levels: [TrackerLevel] {
        let thresholds = TrackerStats.levelThresholds
        return thresholds.enumerated().map { index, start in
            let end = index + 1 < thresholds.count
                ? thresholds[index + 1] - 1
                : nil
            return TrackerLevel(
                number: index + 1,
                startPoints: start,
                endPoints: end
            )
        }
    }
}
