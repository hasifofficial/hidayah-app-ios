//
//  TrackerLevelsViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation
import Observation

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
