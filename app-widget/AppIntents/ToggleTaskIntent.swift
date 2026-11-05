//
//  ToggleTaskIntent.swift
//  app-widgetExtension
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import AppIntents

struct ToggleTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "widget_toggle_task_title"

    @Parameter(title: LocalizedStringResource("widget_task_id_parameter"))
    var id: String

    /// Stand-ins for the shared tracker, set only by tests. The widget
    /// leaves them nil and uses the shared instances.
    @MainActor static var taskManagerOverride: TaskManager?
    @MainActor static var storeOverride: HidayahStore?

    init() {}

    init(
        id: String
    ) {
        self.id = id
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let taskManager = Self.taskManagerOverride ?? TaskManager.shared
        let store = Self.storeOverride ?? HidayahStore.shared
        taskManager.loadTasks()

        // Toggling an in-memory copy would flip the widget for a change that
        // is never saved.
        guard store.isPersistent else {
            throw store.loadError ?? HidayahStore.StoreError.appGroupUnavailable
        }

        if let task = taskManager.tasks.first(where: { $0.id.uuidString == id }) {
            taskManager.toggleTaskCompletion(task: task)
        }
        return .result()
    }
}
