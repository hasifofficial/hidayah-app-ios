//
//  TrackerDayDetailView.swift
//  simple-quran
//

import SwiftUI

struct TrackerDayDetailView: View {
    let dayKey: String
    let record: TrackerDayRecord?

    @Environment(TaskManager.self) private var taskManager

    private var calendar: Calendar {
        TrackerDayKey.calendar
    }

    private var date: Date? {
        TrackerDayKey.date(from: dayKey, calendar: calendar)
    }

    private var gregorianDateText: String {
        guard let date else { return dayKey }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var islamicDateText: String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamic)
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var categoryOrder: [String: Int] {
        Dictionary(
            uniqueKeysWithValues: taskManager.allCategories()
                .enumerated()
                .map { ($0.element.id, $0.offset) }
        )
    }

    private var groupedTasks: [(categoryID: String, tasks: [TrackerTaskSnapshot])] {
        guard let record else { return [] }
        return Dictionary(grouping: record.tasks, by: \.categoryID)
            .map { (categoryID: $0.key, tasks: $0.value) }
            .sorted {
                let leftOrder = categoryOrder[$0.categoryID] ?? Int.max
                let rightOrder = categoryOrder[$1.categoryID] ?? Int.max

                if leftOrder == rightOrder {
                    return ($0.tasks.first?.categoryName ?? "")
                        < ($1.tasks.first?.categoryName ?? "")
                }
                return leftOrder < rightOrder
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroCard
                    .loadAnimation(offset: 14)

                if record == nil {
                    emptyState
                        .loadAnimation(delay: 0.08)
                } else {
                    ForEach(
                        Array(groupedTasks.enumerated()),
                        id: \.element.categoryID
                    ) { index, group in
                        categoryCard(group)
                            .loadAnimation(
                                delay: min(Double(index) * 0.04, 0.3),
                                offset: 12
                            )
                    }
                }
            }
            .padding(16)
        }
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("tracker_day_detail_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                progressRing

                VStack(alignment: .leading, spacing: 4) {
                    Text(gregorianDateText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.title)

                    Text(islamicDateText)
                        .font(.system(size: 12))
                        .foregroundColor(.textGray)

                    if let record, record.isPerfectDay {
                        Label {
                            Text(
                                NSLocalizedString(
                                    "tracker_day_perfect_title",
                                    comment: ""
                                )
                            )
                        } icon: {
                            Image(systemName: "star.fill")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                metricTile(
                    value: "\(record?.completedCount ?? 0)/\(record?.totalCount ?? 0)",
                    label: "tracker_day_tasks_label",
                    icon: "checkmark.circle.fill",
                    color: .lightGreen
                )

                metricTile(
                    value: "\(record?.points ?? 0)",
                    label: "tracker_day_points_label",
                    icon: "bolt.fill",
                    color: .yellow
                )
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.14),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
    }

    private var progressRing: some View {
        let progress = record?.progress ?? 0

        return ZStack {
            Circle()
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 7)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1)))
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(
                        lineWidth: 7,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.title)
        }
        .frame(width: 78, height: 78)
    }

    private func metricTile(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.title)

                Text(NSLocalizedString(label, comment: ""))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textGray)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.appBackground.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func categoryCard(
        _ group: (categoryID: String, tasks: [TrackerTaskSnapshot])
    ) -> some View {
        let completed = group.tasks.filter(\.isCompleted).count
        let total = group.tasks.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.lightGreen.opacity(0.12))

                    Image(
                        systemName: group.tasks.first?.categoryIcon
                            ?? "folder"
                    )
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.lightGreen)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.tasks.first?.categoryName ?? "")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.title)

                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_tasks_completed_format",
                                comment: ""
                            ),
                            completed,
                            total
                        )
                    )
                    .font(.system(size: 11))
                    .foregroundColor(.textGray)
                }

                Spacer(minLength: 8)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.textGray.opacity(0.14))

                    Capsule()
                        .fill(Color.lightGreen)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 5)

            VStack(spacing: 2) {
                ForEach(group.tasks) { task in
                    HStack(spacing: 12) {
                        Image(
                            systemName: task.isCompleted
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(
                            task.isCompleted
                                ? .lightGreen
                                : .textGray.opacity(0.5)
                        )

                        Text(task.name)
                            .font(.system(size: 14))
                            .foregroundColor(
                                task.isCompleted ? .textGray : .title
                            )
                            .strikethrough(task.isCompleted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(16)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(
                    NSLocalizedString(
                        "tracker_day_empty_title",
                        comment: ""
                    )
                )
            } icon: {
                Image(systemName: "calendar")
            }
        } description: {
            Text(
                NSLocalizedString(
                    "tracker_day_empty_subtitle",
                    comment: ""
                )
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
