//
//  TrackerSummaryCardView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct TrackerSummaryCardView: View {
    @Environment(TaskManager.self) private var taskManager

    var onSelectLevel: () -> Void = {}

    private var completedCount: Int {
        taskManager.tasks.filter(\.isCompleted).count
    }

    private var progress: Double {
        guard !taskManager.tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(taskManager.tasks.count)
    }

    private var stats: TrackerStats {
        taskManager.stats
    }

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: Date())
    }

    private func todayIslamicDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamic)
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                progressRing

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("tracker_today_title", comment: ""))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textGray)
                        .textCase(.uppercase)

                    Text(todayDateString())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.title)

                    Text(todayIslamicDateString())
                        .font(.system(size: 12))
                        .foregroundColor(.textGray)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                statTile(
                    icon: "flame.fill",
                    value: "\(stats.currentStreak)",
                    label: "tracker_streak_label",
                    color: .lightGreen
                )

                Button(action: onSelectLevel) {
                    statTile(
                        icon: "star.circle.fill",
                        value: "\(stats.level)",
                        label: "tracker_level_label",
                        color: .orange
                    )
                }
                .buttonStyle(.plain)

                statTile(
                    icon: "bolt.fill",
                    value: "\(stats.totalPoints)",
                    label: "tracker_points_label",
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
        ZStack {
            Circle()
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 8)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1)))
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)

            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.title)

                Text("\(completedCount)/\(taskManager.tasks.count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textGray)
            }
        }
        .frame(width: 92, height: 92)
    }

    private func statTile(
        icon: String,
        value: String,
        label: String,
        color: Color
    ) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.title)

            Text(NSLocalizedString(label, comment: ""))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textGray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.appBackground.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
