//
//  EditTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskManager.self) private var taskManager
    @State private var taskName: String
    @State private var selectedCategory: Category?
    @State private var showingDeleteConfirmation = false

    let task: TaskDetails

    init(task: TaskDetails) {
        self.task = task
        _taskName = State(initialValue: task.name)
        _selectedCategory = State(initialValue: task.category)
    }

    private var trimmedName: String {
        taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && selectedCategory != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppFormHeader(
                    icon: "pencil.circle.fill",
                    title: NSLocalizedString("edit_task_intro_title", comment: ""),
                    subtitle: NSLocalizedString("edit_task_intro_subtitle", comment: "")
                )

                AppFormCard(
                    title: NSLocalizedString(
                        "edit_task_task_detail_section_title",
                        comment: ""
                    )
                ) {
                    AppTextField(
                        label: NSLocalizedString(
                            "edit_task_task_detail_task_name",
                            comment: ""
                        ),
                        placeholder: NSLocalizedString(
                            "add_task_task_name_placeholder",
                            comment: ""
                        ),
                        text: $taskName,
                        focusesOnAppear: true
                    )

                    AppCategoryMenu(
                        label: NSLocalizedString(
                            "edit_task_task_detail_category",
                            comment: ""
                        ),
                        placeholder: NSLocalizedString(
                            "add_task_task_detail_category_placeholder",
                            comment: ""
                        ),
                        categories: taskManager.allCategories(),
                        selection: $selectedCategory
                    )
                }

                AppPrimaryButton(
                    title: NSLocalizedString("edit_task_save_button", comment: ""),
                    icon: "checkmark",
                    isEnabled: canSave
                ) {
                    save()
                }

                AppDestructiveButton(
                    title: NSLocalizedString("edit_task_delete_task_button", comment: ""),
                    icon: "trash"
                ) {
                    showingDeleteConfirmation = true
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("edit_task_header_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            NSLocalizedString("edit_task_delete_task_confirmation_dialog_title", comment: ""),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                NSLocalizedString(
                    "edit_task_delete_task_confirmation_dialog_delete_button",
                    comment: ""
                ),
                role: .destructive
            ) {
                taskManager.deleteTask(task: task)
                dismiss()
            }
            Button(
                NSLocalizedString(
                    "edit_task_delete_task_confirmation_dialog_cancel_button",
                    comment: ""
                ),
                role: .cancel
            ) {}
        } message: {
            Text(NSLocalizedString("edit_task_delete_task_confirmation_dialog_subtitle", comment: ""))
        }
    }

    private func save() {
        guard canSave, let selectedCategory else { return }

        taskManager.updateTask(
            task: task,
            newName: trimmedName,
            newCategory: selectedCategory
        )
        dismiss()
    }
}
