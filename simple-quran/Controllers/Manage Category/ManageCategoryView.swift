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
            if !taskManager.customCategories.isEmpty {
                Form {
                    if !taskManager.customCategories.isEmpty {
                        Section(footer: Text("setting_manage_category_footer_title")) {
                            ForEach(taskManager.customCategories) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.name)
                                    Spacer()
                                }
                            }
                            .onDelete(perform: deleteCategories)
                        }
                    }
                }
            } else {
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
            }
        }
        .navigationTitle("setting_manage_category_header_title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ManageCategoryView: View {
    let taskManager: TaskManager
    
    var body: some View {
        ManageCategoryContentView()
            .environment(taskManager)
    }
}
