//
//  EditTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskManager: TaskManager
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
            Section(header: Text("edit_task_task_detail_section_title")) {
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
                        Text("edit_task_delete_task_button")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("edit_task_header_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("edit_task_save_button") {
                    taskManager.updateTask(
                        task: task,
                        newName: taskName,
                        newCategory: selectedCategory
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(taskName.isEmpty)
                .foregroundColor(Color(uiColor: .lightGreen))
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
            Text("edit_task_delete_task_confirmation_dialog_subtitle")
        }
    }
}
