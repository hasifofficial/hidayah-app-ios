//
//  AddTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TaskManager.self) private var taskManager

    @State private var taskName = ""
    @State private var selectedCategory: Category?

    private var trimmedName: String {
        taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TrackerFormIntro(
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

                    TrackerFormCard(
                        title: NSLocalizedString(
                            "add_task_task_detail_section_title",
                            comment: ""
                        )
                    ) {
                        TrackerFormTextField(
                            label: NSLocalizedString(
                                "add_task_task_detail_task_name",
                                comment: ""
                            ),
                            placeholder: NSLocalizedString(
                                "add_task_task_name_placeholder",
                                comment: ""
                            ),
                            text: $taskName
                        )

                        categoryField
                    }

                    TrackerPrimaryButton(
                        title: NSLocalizedString(
                            "add_task_task_detail_add_task_button",
                            comment: ""
                        ),
                        icon: "plus",
                        isEnabled: canSave
                    ) {
                        guard canSave, let category = selectedCategory else {
                            return
                        }
                        taskManager.addTask(
                            name: trimmedName,
                            category: category
                        )
                        dismiss()
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
                if selectedCategory == nil {
                    selectedCategory = taskManager.allCategories().first
                }
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
                ForEach(taskManager.allCategories(), id: \.id) { category in
                    Button {
                        selectedCategory = category
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
                            systemName: selectedCategory?.icon ?? "square.grid.2x2"
                        )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.lightGreen)
                    }
                    .frame(width: 30, height: 30)

                    Text(
                        selectedCategory?.name
                            ?? NSLocalizedString(
                                "add_task_task_detail_category_placeholder",
                                comment: ""
                            )
                    )
                    .font(.system(size: 14))
                    .foregroundColor(
                        selectedCategory == nil ? .textGray : .title
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
