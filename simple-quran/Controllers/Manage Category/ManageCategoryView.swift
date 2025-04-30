//
//  ManageCategoryView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/2/25.
//

import SwiftUI

struct ManageCategoryContentView: View {
    @EnvironmentObject var taskManager: TaskManager

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
        NavigationView {
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
                VStack {
                    Text("setting_manage_category_empty_title")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(uiColor: .title))
                        .multilineTextAlignment(.center)

                    Text("setting_manage_category_empty_subtitle")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .textGray))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.top, 100)
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
            .environmentObject(taskManager)
    }
}
