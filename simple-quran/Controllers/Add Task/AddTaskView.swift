//
//  AddTaskView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskManager: TaskManager
    @State private var taskName = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("add_task_task_detail_section_title")) {
                    TextField(
                        "add_task_task_detail_task_name",
                        text: $taskName
                    )
                    
                    Picker(
                        "add_task_task_detail_category",
                        selection: $selectedCategory
                    ) {
                        ForEach(taskManager.allCategories(), id: \.id) { category in
                            Label(
                                category.name,
                                systemImage: category.icon
                            )
                            .tag(category as Category?)
                        }
                    }
                }
                
                Section {
                    Button {
                        if let category = selectedCategory {
                            taskManager.addTask(
                                name: taskName,
                                category: category
                            )
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("add_task_task_detail_add_task_button")
                            Spacer()
                        }
                    }
                    .foregroundColor(Color(uiColor: .lightGreen))
                    .disabled(taskName.isEmpty || selectedCategory == nil)
                }
            }
            .navigationTitle("add_task_header_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("add_task_cancel_button") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(uiColor: .lightGreen))
                }
            }
            .onAppear {
                selectedCategory = taskManager.allCategories().first
            }
        }
    }
}
