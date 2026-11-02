//
//  AddCategoryViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import Foundation
import Observation

@Observable
final class AddCategoryViewModel {
    let icons = [
        "folder",
        "bookmark",
        "star",
        "heart",
        "flag",
        "calendar",
        "alarm",
        "moon.stars",
        "sunrise",
        "sun.max",
        "book",
        "checklist",
        "drop",
        "figure.walk",
        "hands.and.sparkles",
        "sparkles"
    ]

    var categoryName = ""
    var iconName = "folder"

    private var trimmedName: String {
        categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    func save(using taskManager: TaskManager) -> Bool {
        guard canSave else { return false }

        taskManager.addCustomCategory(
            name: trimmedName,
            icon: iconName
        )
        return true
    }
}
