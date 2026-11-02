//
//  TrackerAchievementsView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct TrackerAchievementsView: View {
    @State private var viewModel: TrackerAchievementsViewModel

    init(taskManager: TaskManager) {
        _viewModel = State(
            initialValue: TrackerAchievementsViewModel(
                taskManager: taskManager
            )
        )
    }

    private var stats: TrackerStats {
        viewModel.stats
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                levelCard
                    .loadAnimation(offset: 14)

                summaryGrid
                    .loadAnimation(delay: 0.05)

                badgesSection
                    .loadAnimation(delay: 0.1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("tracker_achievements_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: viewModel.shareSummary) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(
                    NSLocalizedString(
                        "tracker_share_achievements",
                        comment: ""
                    )
                )
            }
        }
    }

    private var levelCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        String(
                            format: NSLocalizedString(
                                "tracker_level_format",
                                comment: ""
                            ),
                            stats.level
                        )
                    )
                    .font(.system(size: 21, weight: .bold))
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

                Spacer(minLength: 4)

                ZStack {
                    Circle()
                        .fill(Color.lightGreen.opacity(0.16))
                        .frame(width: 64, height: 64)
                        .blur(radius: 12)

                    BadgeMedalView(
                        icon: "trophy.fill",
                        colors: [Color.orange, Color.yellow],
                        unlocked: true,
                        size: 62
                    )
                }
            }

            ProgressView(value: stats.progressToNextLevel)
                .tint(.lightGreen)

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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            summaryCard(
                title: "tracker_stats_current_streak",
                value: "\(stats.currentStreak)",
                icon: "flame.fill",
                color: .lightGreen
            )
            summaryCard(
                title: "tracker_stats_longest_streak",
                value: "\(stats.longestStreak)",
                icon: "flame",
                color: .orange
            )
            summaryCard(
                title: "tracker_stats_perfect_days",
                value: "\(stats.perfectDays)",
                icon: "star.circle.fill",
                color: .yellow
            )
            summaryCard(
                title: "tracker_stats_completed_tasks",
                value: "\(stats.totalCompletedTasks)",
                icon: "checkmark.circle.fill",
                color: .lightGreen
            )
        }
    }

    private func summaryCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.title)

            Text(NSLocalizedString(title, comment: ""))
                .font(.system(size: 12))
                .foregroundColor(.textGray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(NSLocalizedString("tracker_badges_title", comment: ""))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.title)

                Spacer()

                Text(
                    String(
                        format: NSLocalizedString(
                            "tracker_badges_unlocked_count",
                            comment: ""
                        ),
                        stats.unlockedBadges.count,
                        TrackerBadge.allCases.count
                    )
                )
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textGray)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TrackerBadge.allCases) { badge in
                    badgeCard(badge)
                }
            }
        }
    }

    private func badgeCard(_ badge: TrackerBadge) -> some View {
        let unlocked = stats.unlockedBadges.contains(badge)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                BadgeMedalView(
                    icon: badge.icon,
                    colors: badge.medalColors,
                    unlocked: unlocked
                )

                Spacer(minLength: 4)

                if unlocked {
                    ShareLink(item: viewModel.shareText(for: badge)) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.lightGreen)
                            .frame(width: 28, height: 28)
                            .background(Color.lightGreen.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(
                        NSLocalizedString(
                            "tracker_share_badge",
                            comment: ""
                        )
                    )
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textGray.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(Color.textGray.opacity(0.08))
                        .clipShape(Circle())
                }
            }

            Text(badge.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(unlocked ? .title : .textGray)

            Text(badge.detail)
                .font(.system(size: 11))
                .foregroundColor(.textGray)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            if !unlocked {
                ProgressView(value: stats.progress(for: badge))
                    .tint(.lightGreen)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 185, alignment: .topLeading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    unlocked
                        ? LinearGradient(
                            colors: [
                                badge.medalColors.first?
                                    .opacity(0.12) ?? Color.clear,
                                Color.backgroundGray
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color.backgroundGray,
                                Color.backgroundGray
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    unlocked
                        ? (badge.medalColors.first?.opacity(0.2)
                            ?? Color.clear)
                        : Color.textGray.opacity(0.06),
                    lineWidth: 1
                )
        }
        .opacity(unlocked ? 1 : 0.78)
    }

}

private struct BadgeMedalView: View {
    let icon: String
    let colors: [Color]
    let unlocked: Bool
    var size: CGFloat = 76

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var shimmer = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(unlocked ? 0.16 : 0.06))
                .offset(y: 4)
                .blur(radius: 5)

            Circle()
                .fill(
                    LinearGradient(
                        colors: unlocked
                            ? colors
                            : [
                                Color.textGray.opacity(0.28),
                                Color.textGray.opacity(0.12)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: unlocked
                            ? [
                                Color.white.opacity(0.8),
                                colors.first?.opacity(0.3) ?? .clear,
                                Color.white.opacity(0.45),
                                colors.last?.opacity(0.25) ?? .clear,
                                Color.white.opacity(0.8)
                            ]
                            : [
                                Color.white.opacity(0.35),
                                Color.textGray.opacity(0.2),
                                Color.white.opacity(0.25)
                            ],
                        center: .center
                    ),
                    lineWidth: 2.5
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(unlocked ? 0.3 : 0.12),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size * 0.7
                    )
                )

            Image(systemName: icon)
                .font(
                    .system(
                        size: size * 0.32,
                        weight: .semibold
                    )
                )
                .foregroundColor(unlocked ? .white : .textGray)
                .shadow(
                    color: .black.opacity(unlocked ? 0.18 : 0),
                    radius: 2,
                    y: 1
                )

            if unlocked {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.55),
                                Color.white.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.16)
                    .rotationEffect(.degrees(28))
                    .offset(x: shimmer ? size * 0.55 : -size * 0.55)
                    .mask(Circle())
                    .allowsHitTesting(false)
            }

            if !unlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.textGray)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color.backgroundGray, lineWidth: 2)
                    }
                    .offset(
                        x: size * 0.28,
                        y: size * 0.28
                    )
            }
        }
        .frame(width: size, height: size)
        .rotation3DEffect(
            .degrees(-7),
            axis: (x: 1, y: 1, z: 0),
            perspective: 0.45
        )
        .scaleEffect(appeared ? 1 : 0.82)
        .onAppear {
            guard !appeared else { return }

            if reduceMotion {
                appeared = true
            } else {
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.65)
                ) {
                    appeared = true
                }

                if unlocked {
                    withAnimation(
                        .easeInOut(duration: 1.1).delay(0.2)
                    ) {
                        shimmer = true
                    }
                }
            }
        }
    }
}

private extension TrackerBadge {
    var medalColors: [Color] {
        switch self {
        case .firstStep:
            return [Color.lightGreen, Color.teal]
        case .streak3, .streak7, .streak30:
            return [Color.orange, Color.red]
        case .perfectDay, .perfectTen:
            return [Color.yellow, Color.orange]
        case .century, .devoted:
            return [Color(red: 0.83, green: 0.64, blue: 0.22), Color.brown]
        }
    }
}
