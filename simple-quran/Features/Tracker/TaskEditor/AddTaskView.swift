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
                            text: $viewModel.taskName
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
        VStack(alignment: .leading, spacing: 7) {
            Text(
                NSLocalizedString(
                    "add_task_task_detail_category",
                    comment: ""
                )
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.textGray)

            Menu {
                ForEach(viewModel.categories, id: \.id) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Label(category.name, systemImage: category.icon)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.lightGreen.opacity(0.14))

                        Image(
                            systemName: viewModel.selectedCategory?.icon ?? "square.grid.2x2"
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.lightGreen)
                    }
                    .frame(width: 30, height: 30)

                    Text(
                        viewModel.selectedCategory?.name
                            ?? NSLocalizedString(
                                "add_task_task_detail_category_placeholder",
                                comment: ""
                            )
                    )
                    .font(.system(size: 14))
                    .foregroundColor(
                        viewModel.selectedCategory == nil ? .textGray : .title
                    )
                    .lineLimit(1)

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.textGray)
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color.appBackground.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}
