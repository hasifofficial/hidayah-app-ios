//
//  WidgetContext.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation

struct WidgetContext: Codable {
    let progress: Double
    let completedTasks: Int
    let totalTasks: Int
    let upcomingTasks: [TaskDetails]
}
