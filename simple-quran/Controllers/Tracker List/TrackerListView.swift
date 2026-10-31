//
//  TrackerListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import SwiftUI

struct TrackerListContentView: View {
    @Environment(TaskManager.self) private var taskManager
    @State private var showingAddCategory = false
    @State private var showingAddTask = false

    let onOpenSettings: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressHeaderView()
                        .padding(.top)

                    ForEach(taskManager.allCategories(), id: \.id) { category in
                        if !taskManager.tasks(for: category).isEmpty {
                            TaskCardView(category: category)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Menu {
                Button {
                    showingAddTask = true
                } label: {
                    Label(
                        "tracker_list_add_task_floating_button",
                        systemImage: "plus.circle"
                    )
                }

                Button {
                    showingAddCategory = true
                } label: {
                    Label(
                        "tracker_list_add_category_floating_button",
                        systemImage: "square.grid.2x2"
                    )
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(.lightGreen)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .navigationTitle("tracker_list_header_title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onOpenSettings) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .onAppear {
            taskManager.loadTasks()
        }
    }
}

struct TrackerListView: View {
    let taskManager: TaskManager
    let onOpenSettings: () -> Void

    var body: some View {
        TrackerListContentView(onOpenSettings: onOpenSettings)
            .environment(taskManager)
    }
}
