//
//  WatchTrackerView.swift
//  hidayah-app-watch
//

import SwiftUI

/// Today's Istiqamah tasks, grouped by category. Ticking a task here is sent
/// to the iPhone, which owns the tracker.
struct WatchTrackerView: View {
    let model: WatchTrackerModel

    var body: some View {
        TimelineView(.everyMinute) { context in
            content(now: context.date)
        }
        .navigationTitle(String(localized: "watch_tracker_title"))
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let state = model.state
        if state.snapshot == nil {
            WatchTrackerMessage(
                title: String(localized: "watch_tracker_empty_title"),
                message: String(localized: "watch_tracker_empty_message")
            )
        } else {
            let tasks = state.tasks(now: now)
            let isStale = state.isStale(now: now)
            List {
                Section {
                    WatchTrackerHeader(
                        completed: tasks.filter(\.isCompleted).count,
                        total: tasks.count,
                        streak: state.hasRolledOver(now: now)
                            ? nil
                            : state.snapshot?.currentStreak
                    )
                    .listRowBackground(Color.clear)

                    if isStale {
                        Text(String(localized: "watch_tracker_stale_message"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.clear)
                    }
                }

                ForEach(Self.grouped(tasks), id: \.category.id) { group in
                    Section {
                        ForEach(group.tasks) { task in
                            WatchTaskRow(task: task) {
                                model.toggle(task, now: Date())
                            }
                            .disabled(isStale)
                        }
                    } header: {
                        Label(group.category.name, systemImage: group.category.icon)
                    }
                }
            }
        }
    }

    /// Tasks grouped by category, in the order categories first appear.
    static func grouped(
        _ tasks: [TaskDetails]
    ) -> [(category: Category, tasks: [TaskDetails])] {
        var groups: [(category: Category, tasks: [TaskDetails])] = []
        var indexByID: [String: Int] = [:]
        for task in tasks {
            if let index = indexByID[task.category.id] {
                groups[index].tasks.append(task)
            } else {
                indexByID[task.category.id] = groups.count
                groups.append((task.category, [task]))
            }
        }
        return groups
    }
}

private struct WatchTrackerHeader: View {
    let completed: Int
    let total: Int
    let streak: Int?

    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.lightGreen.opacity(0.25), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.lightGreen,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption2.bold())
                    .monospacedDigit()
            }
            .frame(width: 48, height: 48)
            .animation(.easeInOut, value: progress)

            VStack(alignment: .leading, spacing: 2) {
                Text(
                    String(
                        format: String(localized: "watch_tracker_progress_format"),
                        completed,
                        total
                    )
                )
                .font(.headline)
                .monospacedDigit()

                if total > 0, completed == total {
                    Text(String(localized: "watch_tracker_all_done"))
                        .font(.caption2)
                        .foregroundStyle(Color.lightGreen)
                } else if let streak, streak > 0 {
                    Label(
                        String(
                            format: String(localized: "watch_tracker_streak_format"),
                            streak
                        ),
                        systemImage: "flame.fill"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WatchTaskRow: View {
    let task: TaskDetails
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? Color.lightGreen : .secondary)
                    .font(.title3)
                Text(task.name)
                    .font(.footnote)
                    .lineLimit(3)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
            }
        }
        .accessibilityAddTraits(task.isCompleted ? .isSelected : [])
    }
}

private struct WatchTrackerMessage: View {
    let title: String
    let message: String

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "iphone.and.arrow.forward")
                    .font(.title2)
                    .foregroundStyle(Color.lightGreen)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
