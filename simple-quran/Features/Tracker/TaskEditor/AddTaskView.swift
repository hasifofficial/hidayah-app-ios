//
//  AddTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskManager.self) private var taskManager

    @State private var viewModel = AddTaskViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppFormHeader(
                        icon: "plus.circle.fill",
                        title: NSLocalizedString(
                            "add_task_intro_title",
                            comment: ""
                        ),
                        subtitle: NSLocalizedString(
                            "add_task_intro_subtitle",
                            comment: ""
                        )
                    )

                    AppFormCard(
                        title: NSLocalizedString(
                            "add_task_task_detail_section_title",
                            comment: ""
                        )
                    ) {
                        AppTextField(
                            label: NSLocalizedString(
                                "add_task_task_detail_task_name",
                                comment: ""
                            ),
                            placeholder: NSLocalizedString(
                                "add_task_task_name_placeholder",
                                comment: ""
                            ),
                            text: $viewModel.taskName,
                            focusesOnAppear: true
                        )

                        categoryField
                    }

                    AppPrimaryButton(
                        title: NSLocalizedString(
                            "add_task_task_detail_add_task_button",
                            comment: ""
                        ),
                        icon: "plus",
                        isEnabled: viewModel.canSave
                    ) {
                        if viewModel.save(using: taskManager) {
                            dismiss()
                        }
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(.appBackground)
            .navigationTitle(
                NSLocalizedString("add_task_header_title", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        NSLocalizedString(
                            "add_task_cancel_button",
                            comment: ""
                        )
                    ) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .onAppear {
                viewModel.configure(with: taskManager)
            }
        }
    }

    private var categoryField: some View {
        AppCategoryMenu(
            label: NSLocalizedString(
                "add_task_task_detail_category",
                comment: ""
            ),
            placeholder: NSLocalizedString(
                "add_task_task_detail_category_placeholder",
                comment: ""
            ),
            categories: viewModel.categories,
            selection: $viewModel.selectedCategory
        )
    }
}
