//
//  AddTaskViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

@Observable
final class AddTaskViewModel {
    var taskName = ""
    var selectedCategory: Category?
    private(set) var categories: [Category] = []

    var canSave: Bool {
        !trimmedName.isEmpty && selectedCategory != nil
    }

    private var trimmedName: String {
        taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func configure(with taskManager: TaskManager) {
        categories = taskManager.allCategories()
        if selectedCategory == nil {
            selectedCategory = categories.first
        }
    }

    func save(using taskManager: TaskManager) -> Bool {
        guard canSave, let selectedCategory else { return false }

        taskManager.addTask(
            name: trimmedName,
            category: selectedCategory
        )
        return true
    }
}
