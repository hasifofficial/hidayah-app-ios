//
//  TrackerListView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerListContentView: View {
    @Environment(TaskManager.self) private var taskManager
    @State private var showingAddCategory = false
    @State private var showingAddTask = false

    let onOpenCalendar: () -> Void
    let onOpenAchievements: () -> Void
    let onOpenLevels: () -> Void
    let onOpenSettings: () -> Void

    private var completedCount: Int {
        taskManager.tasks.filter(\.isCompleted).count
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    TrackerSummaryCardView(onSelectLevel: onOpenLevels)
                        .loadAnimation(offset: 14)

                    HStack(alignment: .firstTextBaseline) {
                        Text(
                            NSLocalizedString(
                                "tracker_today_tasks_title",
                                comment: ""
                            )
                        )
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.title)

                        Spacer()

                        Text("\(completedCount)/\(taskManager.tasks.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textGray)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .loadAnimation(delay: 0.05)

                    if taskManager.tasks.isEmpty {
                        emptyState
                            .loadAnimation(delay: 0.08)
                    } else {
                        ForEach(
                            Array(taskManager.allCategories().enumerated()),
                            id: \.element.id
                        ) { index, category in
                            if !taskManager.tasks(for: category).isEmpty {
                                TrackerCategoryCardView(category: category)
                                    .loadAnimation(
                                        delay: min(
                                            Double(index) * 0.04,
                                            0.35
                                        ),
                                        offset: 14
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(.appBackground)

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
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.lightGreen)
                    .clipShape(Circle())
                    .shadow(
                        color: Color.lightGreen.opacity(0.32),
                        radius: 12,
                        y: 6
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .navigationTitle(
            NSLocalizedString("tracker_list_header_title", comment: "")
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: onOpenCalendar) {
                    Image(systemName: "calendar")
                        .foregroundColor(.primary)
                }
                .accessibilityIdentifier("trackerCalendarButton")

                Button(action: onOpenAchievements) {
                    Image(systemName: "trophy")
                        .foregroundColor(.primary)
                }
                .accessibilityIdentifier("trackerAchievementsButton")

                Button(action: onOpenSettings) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
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

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "tracker_empty_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "checklist")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "tracker_empty_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

struct TrackerListView: View {
    let taskManager: TaskManager
    let onOpenCalendar: () -> Void
    let onOpenAchievements: () -> Void
    let onOpenLevels: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        TrackerListContentView(
            onOpenCalendar: onOpenCalendar,
            onOpenAchievements: onOpenAchievements,
            onOpenLevels: onOpenLevels,
            onOpenSettings: onOpenSettings
        )
        .environment(taskManager)
    }
}
