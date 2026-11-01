//
//  ManageCategoryView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/2/25.
//

import SwiftUI

struct ManageCategoryContentView: View {
    @Environment(TaskManager.self) private var taskManager

    private func deleteCategories(at offsets: IndexSet) {
        offsets.forEach { index in
            let category = taskManager.customCategories[index]
            taskManager.tasks.removeAll { task in
                if case .custom(let custom) = task.category {
                    return custom.id == category.id
                }
                return false
            }
            taskManager.customCategories.remove(at: index)
        }
        taskManager.saveData()
    }

    var body: some View {
        Group {
            if taskManager.customCategories.isEmpty {
                emptyState
            } else {
                List {
                    SettingsSectionHeader(
                        title: NSLocalizedString(
                            "setting_manage_category_section_title",
                            comment: ""
                        ),
                        topPadding: 16
                    )

                    ForEach(taskManager.customCategories) { category in
                        categoryRow(category)
                    }
                    .onDelete(perform: deleteCategories)

                    Text(
                        NSLocalizedString(
                            "setting_manage_category_footer_title",
                            comment: ""
                        )
                    )
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                    .settingsListRow()
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(.sheetBackground)
            }
        }
        .navigationTitle(
            NSLocalizedString(
                "setting_manage_category_header_title",
                comment: ""
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryRow(_ category: CustomCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)

            Text(category.name)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .settingsListRow()
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "setting_manage_category_empty_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "square.grid.2x2")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "setting_manage_category_empty_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.sheetBackground)
    }
}

struct ManageCategoryView: View {
    let taskManager: TaskManager

    var body: some View {
        ManageCategoryContentView()
            .environment(taskManager)
    }
}
