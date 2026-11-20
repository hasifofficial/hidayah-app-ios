//
//  TrackerDayDetailViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TrackerDayDetailViewModel {
    let dayKey: String
    let record: TrackerDayRecord?

    private let taskManager: TaskManager
    private var calendar: Calendar { TrackerDayKey.calendar }

    init(
        taskManager: TaskManager,
        dayKey: String,
        record: TrackerDayRecord?
    ) {
        self.taskManager = taskManager
        self.dayKey = dayKey
        self.record = record
    }

    var date: Date? {
        TrackerDayKey.date(from: dayKey, calendar: calendar)
    }

    var gregorianDateText: String {
        guard let date else { return dayKey }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    var islamicDateText: String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamic)
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Default category names are looked up when shown rather than taken from
    /// the snapshot: a day saved outside the app, e.g. from the widget, holds
    /// the untranslated key. Custom categories keep the name they had that day.
    func categoryName(
        for group: (categoryID: String, tasks: [TrackerTaskSnapshot])
    ) -> String {
        if let category = DefaultCategory(categoryID: group.categoryID) {
            return category.displayName
        }
        return group.tasks.first?.categoryName ?? ""
    }

    var groupedTasks: [(categoryID: String, tasks: [TrackerTaskSnapshot])] {
        guard let record else { return [] }

        let categoryOrder = Dictionary(
            uniqueKeysWithValues: taskManager.allCategories()
                .enumerated()
                .map { ($0.element.id, $0.offset) }
        )

        return Dictionary(grouping: record.tasks, by: \.categoryID)
            .map { (categoryID: $0.key, tasks: $0.value) }
            .sorted {
                let leftOrder = categoryOrder[$0.categoryID] ?? Int.max
                let rightOrder = categoryOrder[$1.categoryID] ?? Int.max

                if leftOrder == rightOrder {
                    return ($0.tasks.first?.categoryName ?? "")
                        < ($1.tasks.first?.categoryName ?? "")
                }
                return leftOrder < rightOrder
            }
    }
}
