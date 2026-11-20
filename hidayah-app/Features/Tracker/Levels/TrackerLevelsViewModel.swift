//
//  TrackerLevelsViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TrackerLevelsViewModel {
    private let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager
    }

    var stats: TrackerStats {
        taskManager.stats
    }

    var levels: [TrackerLevel] {
        TrackerLevelCatalog.levels
    }
}
