//
//  WatchTrackerView.swift
//  hidayah-app-watch
//

import SwiftUI

/// Today's Istiqamah tasks, grouped by category. Ticking a task here is sent
/// to the iPhone, which owns the tracker.
struct WatchTrackerView: View {
    let model: WatchTrackerModel

    private enum Page: Hashable {
        case progress
        case tasks
    }

    @State private var page = Page.progress

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
            // Two vertical pages, like the Activity app: today's progress
            // first, then the tasks. Swipe up or turn the Digital Crown.
            TabView(selection: $page) {
                WatchTrackerProgressPage(
                    completed: tasks.filter(\.isCompleted).count,
                    total: tasks.count,
                    streak: state.hasRolledOver(now: now)
                        ? nil
                        : state.snapshot?.currentStreak,
                    level: state.snapshot?.level,
                    isStale: isStale,
                    isVisible: page == .progress
                )
                .tag(Page.progress)

                List {
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
                .tag(Page.tasks)
            }
            .tabViewStyle(.verticalPage)
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

/// The first page: today's progress as a ring that fills the screen. The
/// ring fills from empty each time the page comes into view.
private struct WatchTrackerProgressPage: View {
    let completed: Int
    let total: Int
    let streak: Int?
    let level: Int?
    let isStale: Bool
    let isVisible: Bool

    private static let lineWidth: CGFloat = 14

    /// What the ring and percentage show; animated toward `progress`.
    @State private var shownProgress = 0.0

    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }

    private var isDone: Bool {
        total > 0 && completed == total
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // A stroke is centred on the shape's edge, so inset the
                // circle by half the line width to keep the whole ring
                // inside its frame instead of over the pill below.
                Circle()
                    .inset(by: Self.lineWidth / 2)
                    .stroke(Color.lightGreen.opacity(0.22), lineWidth: Self.lineWidth)
                Circle()
                    .inset(by: Self.lineWidth / 2)
                    .trim(from: 0, to: shownProgress)
                    .stroke(
                        Color.lightGreen,
                        style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(Int((shownProgress * 100).rounded()))%")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: shownProgress))
                    Text(
                        String(
                            format: String(localized: "watch_tracker_progress_format"),
                            completed,
                            total
                        )
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)

            footer
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
        // Wait for the push, or for the page to finish sliding in, so the
        // fill is not hidden behind the transition.
        .onAppear { fill(after: 0.25) }
        .onChange(of: isVisible) { _, visible in
            if visible { fill(after: 0.4) }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.35)) {
                shownProgress = newValue
            }
        }
    }

    /// Empties the ring, then fills it to today's progress after `delay`.
    /// The fill must start in a later update: emptying and filling in the
    /// same one cancel out, and nothing animates.
    private func fill(after delay: TimeInterval) {
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) { shownProgress = 0 }

        let target = progress
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.9)) {
                shownProgress = target
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if isStale {
            Text(String(localized: "watch_tracker_stale_message"))
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 3) {
                HStack(spacing: 8) {
                    if let level {
                        WatchLevelPill(level: level)
                    }
                    if let streak, streak > 0 {
                        Label("\(streak)", systemImage: "flame.fill")
                            .foregroundStyle(.orange)
                            .accessibilityLabel(
                                String(format: String(localized: "watch_tracker_streak_format"), streak)
                            )
                    }
                }
                if isDone {
                    Text(String(localized: "watch_tracker_all_done"))
                        .foregroundStyle(Color.lightGreen)
                } else if level == nil, (streak ?? 0) == 0 {
                    Label(String(localized: "watch_tracker_tasks_hint"), systemImage: "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// The level in a pill, in that level's colour, as on the iPhone's Home.
private struct WatchLevelPill: View {
    let level: Int

    var body: some View {
        let color = LevelColor.forLevel(level)
        Label(
            String(format: String(localized: "watch_tracker_level_format"), level),
            systemImage: "star.circle.fill"
        )
        .font(.caption2.bold())
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(color.opacity(0.18), in: Capsule())
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
