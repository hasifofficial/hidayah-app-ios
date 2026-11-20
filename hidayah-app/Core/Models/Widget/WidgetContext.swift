//
//  WidgetContext.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

struct WidgetContext: Codable {
    let progress: Double
    let completedTasks: Int
    let totalTasks: Int
    let upcomingTasks: [TaskDetails]
    /// The tracker day this snapshot describes. Optional so snapshots written
    /// by older builds still decode.
    let dayKey: String?
    /// What `upcomingTasks` becomes once the day rolls over and every task
    /// is reset, so the widget can show the new day before the app runs.
    let resetUpcomingTasks: [TaskDetails]?
}
