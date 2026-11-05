//
//  TrackerBadge.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

enum TrackerBadge: String, CaseIterable, Identifiable {
    case firstStep
    case streak3
    case streak7
    case streak30
    case perfectDay
    case perfectTen
    case century
    case devoted

    var id: String { rawValue }

    var title: String {
        NSLocalizedString("tracker_badge_\(rawValue)_title", comment: "")
    }

    var detail: String {
        NSLocalizedString("tracker_badge_\(rawValue)_detail", comment: "")
    }

    var icon: String {
        switch self {
        case .firstStep:
            return "sparkles"
        case .streak3, .streak7, .streak30:
            return "flame.fill"
        case .perfectDay, .perfectTen:
            return "star.circle.fill"
        case .century, .devoted:
            return "trophy.fill"
        }
    }

    var target: Int {
        switch self {
        case .firstStep:
            return 1
        case .streak3:
            return 3
        case .streak7:
            return 7
        case .streak30:
            return 30
        case .perfectDay:
            return 1
        case .perfectTen:
            return 10
        case .century:
            return 100
        case .devoted:
            return 1_000
        }
    }
}
