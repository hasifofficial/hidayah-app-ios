//
//  AppIntent.swift
//  app-widget
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import AppIntents

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark selected task as complete"

    @Parameter(title: "Task id")
    var id: String

    init() {}

    init(
        id: String
    ) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        TaskManager.shared.loadTasks()
        if let task = TaskManager.shared.tasks.first(where: { $0.id.uuidString == id }) {
            TaskManager.shared.toggleTaskCompletion(task: task)
        }
        return .result()
    }
}
