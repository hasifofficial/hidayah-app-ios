//
//  WidgetGuideViewModel.swift
//  simple-quran
//

import Foundation
import Observation

enum WidgetGuideKind: String, CaseIterable, Identifiable {
    case tracker
    case quickSurahs

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .tracker:
            return "widget_guide_tracker_title"
        case .quickSurahs:
            return "widget_guide_quick_title"
        }
    }

    var bodyKey: String {
        switch self {
        case .tracker:
            return "widget_guide_tracker_body"
        case .quickSurahs:
            return "widget_guide_quick_body"
        }
    }

    var icon: String {
        switch self {
        case .tracker:
            return "chart.pie.fill"
        case .quickSurahs:
            return "book.closed.fill"
        }
    }
}

struct WidgetGuideSurah: Identifiable {
    let number: Int
    let name: String
    let arabic: String

    var id: Int { number }
}

@Observable
final class WidgetGuideViewModel {
    var selectedWidget: WidgetGuideKind = .tracker

    let quickSurahs = [
        WidgetGuideSurah(number: 18, name: "Al-Kahf", arabic: "الكهف"),
        WidgetGuideSurah(number: 32, name: "As-Sajda", arabic: "السجدة"),
        WidgetGuideSurah(number: 36, name: "Yaseen", arabic: "يس")
    ]

    @ObservationIgnored
    private let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager
    }

    var completedCount: Int {
        taskManager.tasks.filter(\.isCompleted).count
    }

    var totalCount: Int {
        taskManager.tasks.count
    }

    var todayProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var upcomingTasks: [TaskDetails] {
        taskManager.tasks
            .filter { !$0.isCompleted }
            .prefix(3)
            .map { $0 }
    }

    func select(_ kind: WidgetGuideKind) {
        selectedWidget = kind
    }
}
