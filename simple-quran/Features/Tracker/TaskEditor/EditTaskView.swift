//
//  EditTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(TaskManager.self) private var taskManager
    @State private var taskName: String
    @State private var selectedCategory: Category
    @State private var showingDeleteConfirmation = false
    
    let task: TaskDetails

    init(
        task: TaskDetails
    ) {
        self.task = task
        _taskName = State(initialValue: task.name)
        _selectedCategory = State(initialValue: task.category)
    }
    
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("edit_task_task_detail_section_title", comment: ""))) {
                TextField(
                    "edit_task_task_detail_task_name",
                    text: $taskName
                )
                
                Picker(
                    "edit_task_task_detail_category",
                    selection: $selectedCategory
                ) {
                    ForEach(taskManager.allCategories(), id: \.id) { category in
                        Label(
                            category.name,
                            systemImage: category.icon
                        )
                        .tag(category)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text(NSLocalizedString("edit_task_delete_task_button", comment: ""))
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(
            NSLocalizedString("edit_task_header_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("edit_task_save_button", comment: "")) {
                    taskManager.updateTask(
                        task: task,
                        newName: taskName,
                        newCategory: selectedCategory
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(taskName.isEmpty)
                .foregroundColor(.lightGreen)
            }
        }
        .confirmationDialog(
            "edit_task_delete_task_confirmation_dialog_title",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "edit_task_delete_task_confirmation_dialog_delete_button",
                role: .destructive
            ) {
                taskManager.deleteTask(task: task)
                presentationMode.wrappedValue.dismiss()
            }
            Button(
                "edit_task_delete_task_confirmation_dialog_cancel_button",
                role: .cancel
            ) {}
        } message: {
            Text(NSLocalizedString("edit_task_delete_task_confirmation_dialog_subtitle", comment: ""))
        }
    }
}
