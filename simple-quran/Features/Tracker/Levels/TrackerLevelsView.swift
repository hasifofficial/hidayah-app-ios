//
//  TrackerLevelsView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerLevelsView: View {
    @State private var viewModel: TrackerLevelsViewModel

    init(taskManager: TaskManager) {
        _viewModel = State(
            initialValue: TrackerLevelsViewModel(
                taskManager: taskManager
            )
        )
    }

    private var stats: TrackerStats {
        viewModel.stats
    }

    private var levels: [TrackerLevel] {
        viewModel.levels
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                    .loadAnimation(offset: 14)

                howToEarnCard
                    .loadAnimation(delay: 0.05)

                timeline
            }
            .padding(16)
        }
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("tracker_levels_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_level_format",
                                comment: ""
                            ),
                            stats.level
                        )
                    )
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(.title)

                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_points_format",
                                comment: ""
                            ),
                            stats.totalPoints
                        )
                    )
                    .font(.system(size: 13))
                    .foregroundColor(.textGray)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.lightGreen.opacity(0.16), lineWidth: 7)

                    Circle()
                        .trim(from: 0, to: CGFloat(stats.progressToNextLevel))
                        .stroke(
                            Color.lightGreen,
                            style: StrokeStyle(
                                lineWidth: 7,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(stats.level)")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.title)
                }
                .frame(width: 64, height: 64)
            }

            if let nextLevel = stats.nextLevelPoints {
                Text(
                    String(
                        format: NSLocalizedString(
                            "tracker_next_level_format",
                            comment: ""
                        ),
                        nextLevel
                    )
                )
                .font(.system(size: 12))
                .foregroundColor(.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)
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

    private var howToEarnCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.lightGreen.opacity(0.12))

                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(
                    NSLocalizedString(
                        "tracker_levels_how_to_earn_title",
                        comment: ""
                    )
                )
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.title)

                Text(
                    NSLocalizedString(
                        "tracker_levels_how_to_earn_body",
                        comment: ""
                    )
                )
                .font(.system(size: 12))
                .foregroundColor(.textGray)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                levelRow(
                    level,
                    isLast: index == levels.count - 1
                )
                .loadAnimation(
                    delay: min(Double(index) * 0.03, 0.3),
                    offset: 10
                )
            }
        }
    }

    private func levelRow(_ level: TrackerLevel, isLast: Bool) -> some View {
        let isUnlocked = stats.level >= level.number
        let isCurrent = stats.level == level.number

        return HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked
                                ? Color.lightGreen
                                : Color.textGray.opacity(0.18)
                        )

                    if isUnlocked {
                        Text("\(level.number)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.textGray)
                    }
                }
                .frame(width: 32, height: 32)
                .overlay {
                    if isCurrent {
                        Circle()
                            .stroke(Color.lightGreen.opacity(0.3), lineWidth: 5)
                            .scaleEffect(1.18)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(
                            isUnlocked
                                ? Color.lightGreen.opacity(0.28)
                                : Color.textGray.opacity(0.12)
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(level.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            isUnlocked ? .title : .textGray
                        )

                    if isCurrent {
                        Text(
                            NSLocalizedString(
                                "tracker_levels_current",
                                comment: ""
                            )
                        )
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.lightGreen)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.lightGreen.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    if isUnlocked && !isCurrent {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.lightGreen)
                    }
                }

                Text(level.rangeText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textGray)

                if isCurrent {
                    Text(
                        NSLocalizedString(
                            "tracker_levels_you_are_here",
                            comment: ""
                        )
                    )
                    .font(.system(size: 11))
                    .foregroundColor(.lightGreen)
                } else if !isUnlocked {
                    Text(level.unlockText)
                        .font(.system(size: 11))
                        .foregroundColor(.textGray)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                if isCurrent {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.lightGreen.opacity(0.25), lineWidth: 1)
                }
            }
            .opacity(isUnlocked ? 1 : 0.55)
        }
        .padding(.bottom, isLast ? 0 : 4)
    }
}
