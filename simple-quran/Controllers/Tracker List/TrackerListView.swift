//
//  TrackerListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import SwiftUI

struct TrackerListContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAddCategory = false
    @State private var showingAddTask = false
    @State private var showingUIKitSettings = false
    
    let surahService: SurahService

    var body: some View {
        NavigationView {
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
                        .background(Color(uiColor: .lightGreen))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .menuStyle(BorderlessButtonMenuStyle())
            }
            .navigationTitle("tracker_list_header_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUIKitSettings = true
                    }) {
                        Image(systemName: "ellipsis")
                            .tint(.gray)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .sheet(
                isPresented: $showingUIKitSettings
            ) {
                SettingViewControllerWrapper(
                    surahService: surahService,
                    taskManager: taskManager
                )
            }
            .sheet(
                isPresented: $showingAddCategory
            ) {
                AddCategoryView()
            }
            .sheet(
                isPresented: $showingAddTask
            ) {
                AddTaskView()
            }
        }
        .onAppear {
            taskManager.loadTasks()
        }
    }
}

struct TrackerListView: View {
    let surahService: SurahService
    let taskManager: TaskManager
    
    var body: some View {
        TrackerListContentView(
            surahService: surahService
        )
        .environmentObject(taskManager)
    }
}
