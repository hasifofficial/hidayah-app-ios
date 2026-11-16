//
//  HomeView.swift
//  simple-quran
//

import SwiftUI

/// The first tab: today's date, tracker progress, bookmarks and the quick
/// access surahs at a glance.
struct HomeView: View {
    let quranViewModel: SurahListViewModel
    let bookmarkViewModel: BookmarkListViewModel
    let taskManager: TaskManager
    let reflectionModel: HomeReflectionModel
    var now: () -> Date = Date.init

    let onOpenFeature: (AppFeature) -> Void
    let onOpenExplore: () -> Void
    let onOpenTracker: () -> Void
    let onOpenBookmarks: () -> Void
    let onSelectBookmark: (BookmarkedSurah) -> Void
    let onSelectSurah: (SurahListResponse) -> Void
    let onOpenSettings: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var today = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                dateHeader
                    .loadAnimation(offset: 12)

                exploreShortcuts
                    .loadAnimation(delay: 0.04, offset: 12)

                trackerCard
                    .loadAnimation(delay: 0.08, offset: 12)

                quickAccess
                    .loadAnimation(delay: 0.12, offset: 12)

                bookmarksSection
                    .loadAnimation(delay: 0.16, offset: 12)
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
        .background {
            AppGradientBackground()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            logo

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onOpenSettings) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            today = now()
            quranViewModel.loadIfNeeded()
            bookmarkViewModel.loadIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                today = now()
            }
        }
    }

    // MARK: Header

    @ToolbarContentBuilder
    private var logo: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) {
                logoImage
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) {
                logoImage
            }
        }
    }

    private var logoImage: some View {
        Image("hidayah_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 96, height: 44)
            .accessibilityLabel("Hidayah")
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("home_greeting", comment: ""))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.title)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 2) {
                Text(HomeDateFormatter.gregorian(today))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.title)

                Text(HomeDateFormatter.hijri(today))
                    .font(.system(size: 13))
                    .foregroundColor(.textGray)
            }
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    // MARK: Explore

    private var exploreShortcuts: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(AppFeature.homeShortcuts) { feature in
                shortcutTile(icon: feature.icon, assetIcon: feature.assetIcon, title: feature.title) {
                    onOpenFeature(feature)
                }
            }

            shortcutTile(
                icon: "square.grid.2x2.fill",
                title: NSLocalizedString("home_explore_all", comment: ""),
                accessibilityLabel: NSLocalizedString("home_explore_all_accessibility", comment: ""),
                action: onOpenExplore
            )
        }
        .padding(.horizontal, 16)
    }

    private func shortcutTile(
        icon: String,
        assetIcon: String? = nil,
        title: String,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.backgroundGray)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.lightGreen.opacity(0.12), lineWidth: 1)
                        }

                    FeatureIcon(systemName: icon, assetName: assetIcon, size: 20)
                }
                .frame(height: 58)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Cards

    private var trackerCard: some View {
        let total = taskManager.tasks.count
        let completed = taskManager.tasks.filter(\.isCompleted).count
        let stats = taskManager.stats

        return HomeCard(
            icon: "checklist.checked",
            label: NSLocalizedString("tracker_today_tasks_title", comment: ""),
            title: String(
                format: NSLocalizedString("home_tracker_progress_format", comment: ""),
                completed,
                total
            ),
            action: onOpenTracker
        ) {
            VStack(alignment: .leading, spacing: 10) {
                summaryText(
                    fallback: HomeTrackerSummary.message(completed: completed, total: total)
                )

                HStack(spacing: 8) {
                    statChip(
                        icon: "flame.fill",
                        text: String(
                            format: NSLocalizedString("home_tracker_streak_format", comment: ""),
                            stats.currentStreak
                        ),
                        color: .lightGreen
                    )

                    statChip(
                        icon: "star.circle.fill",
                        text: String(
                            format: NSLocalizedString("home_tracker_level_format", comment: ""),
                            stats.level
                        ),
                        color: .orange
                    )

                    statChip(
                        icon: "bolt.fill",
                        text: String(
                            format: NSLocalizedString("home_tracker_points_format", comment: ""),
                            stats.totalPoints
                        ),
                        color: .yellow
                    )
                }
            }
        }
    }

    private var trackerSnapshot: TrackerSnapshot {
        let tasks = taskManager.tasks

        return TrackerSnapshot(
            completed: tasks.filter(\.isCompleted).count,
            total: tasks.count,
            remainingTasks: tasks.filter { !$0.isCompleted }.map(\.name),
            currentStreak: taskManager.stats.currentStreak,
            level: taskManager.stats.level,
            partOfDay: PartOfDay.current(at: today)
        )
    }

    /// The on-device reflection when one is ready, otherwise the built-in
    /// sentence. Generated text gets a sparkle so it reads as AI-written.
    @ViewBuilder
    private func summaryText(fallback: String) -> some View {
        Group {
            if let message = reflectionModel.message {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.lightGreen)
                        .accessibilityHidden(true)

                    Text(message)
                }
                .transition(.opacity)
            } else {
                Text(fallback)
                    .transition(.opacity)
            }
        }
        .font(.system(size: 14))
        .foregroundColor(.title)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut(duration: 0.25), value: reflectionModel.message)
        .task(id: trackerSnapshot) {
            await reflectionModel.generate(for: trackerSnapshot)
        }
    }

    private func statChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.title)
                .monospacedDigit()
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.appBackground.opacity(0.8))
        .clipShape(Capsule())
    }

    // MARK: Quick access

    @ViewBuilder
    private var quickAccess: some View {
        let surahs = quranViewModel.surahs.quickAccessSurahs

        if !surahs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(NSLocalizedString("surah_list_quick_access_title", comment: ""))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(surahs, id: \.number) { surah in
                            Button {
                                onSelectSurah(surah)
                            } label: {
                                QuickAccessSurahCard(surah: surah)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .defaultScrollAnchor(.leading)
            }
        }
    }

    // MARK: Bookmarks

    /// How many bookmarks Home shows; a "See more" card follows when there
    /// are more.
    static let maxBookmarks = 5

    private var bookmarksSection: some View {
        let bookmarks = bookmarkViewModel.bookmarks

        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader(
                NSLocalizedString("bookmark_list_header_title", comment: ""),
                seeAllLabel: NSLocalizedString("home_see_all_bookmarks_accessibility", comment: ""),
                onSeeAll: bookmarks.isEmpty ? nil : onOpenBookmarks
            )

            if bookmarks.isEmpty {
                bookmarksEmptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(bookmarks.prefix(Self.maxBookmarks)) { item in
                            Button {
                                onSelectBookmark(item)
                            } label: {
                                QuickAccessSurahCard(
                                    surah: item.surah,
                                    detail: String(
                                        format: NSLocalizedString("bookmark_list_subtitle", comment: ""),
                                        "\(item.bookmark.numberInSurah)"
                                    ),
                                    icon: "bookmark.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        if bookmarks.count > Self.maxBookmarks {
                            seeMoreCard
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                }
                .defaultScrollAnchor(.leading)
            }
        }
    }

    private var seeMoreCard: some View {
        Button(action: onOpenBookmarks) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.lightGreen.opacity(0.14))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 40, height: 40)

                Text(NSLocalizedString("home_see_more", comment: ""))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.title)
            }
            .frame(width: 110)
            .frame(maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.backgroundGray)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.lightGreen.opacity(0.14), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString("home_see_more_bookmarks_accessibility", comment: ""))
    }

    private var bookmarksEmptyState: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.lightGreen.opacity(0.12))

                Image(systemName: "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(NSLocalizedString("home_bookmarks_empty", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.title)

                Text(NSLocalizedString("bookmark_list_empty_list_subtitle", comment: ""))
                    .font(.system(size: 13))
                    .foregroundColor(.textGray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.backgroundGray)
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: Section header

    /// A section title with an optional "See all" button on the right.
    private func sectionHeader(
        _ title: String,
        seeAllLabel: String? = nil,
        onSeeAll: (() -> Void)? = nil
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.title)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if let onSeeAll {
                Button(action: onSeeAll) {
                    Text(NSLocalizedString("home_see_all", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(seeAllLabel ?? NSLocalizedString("home_see_all", comment: ""))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

/// The encouraging line under today's tracker count on Home.
enum HomeTrackerSummary {
    static func message(completed: Int, total: Int) -> String {
        let remaining = max(total - completed, 0)

        if total == 0 {
            return NSLocalizedString("home_tracker_summary_empty", comment: "")
        }
        if remaining == 0 {
            return NSLocalizedString("home_tracker_summary_done", comment: "")
        }
        if completed == 0 {
            return String(
                format: NSLocalizedString("home_tracker_summary_start", comment: ""),
                total
            )
        }
        if remaining == 1 {
            return NSLocalizedString("home_tracker_summary_one_left", comment: "")
        }

        let percent = Int((Double(completed) / Double(total) * 100).rounded())
        return String(
            format: NSLocalizedString("home_tracker_summary_progress", comment: ""),
            remaining,
            percent
        )
    }
}

/// Today's date on the Gregorian and Hijri calendars for the Home header.
enum HomeDateFormatter {
    static func gregorian(
        _ date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMMyyyy")
        return formatter.string(from: date)
    }

    /// Uses the Umm al-Qura calendar, which can differ by a day from local
    /// moon-sighting announcements.
    static func hijri(
        _ date: Date,
        locale: Locale = Locale(identifier: "en"),
        timeZone: TimeZone = .current
    ) -> String {
        var calendar = Calendar(identifier: .islamicUmmAlQura)
        calendar.timeZone = timeZone

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "d MMMM y"
        return String(
            format: NSLocalizedString("home_hijri_date_format", comment: ""),
            formatter.string(from: date)
        )
    }
}

private struct HomeCard<Footer: View>: View {
    let icon: String
    let label: String
    let title: String
    var trailing: String? = nil
    var isHighlighted = false
    let action: () -> Void
    @ViewBuilder var footer: Footer

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.lightGreen.opacity(0.12))

                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.lightGreen)
                    }
                    .frame(width: 42, height: 42)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textGray)

                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.title)
                            .monospacedDigit()
                    }

                    Spacer(minLength: 8)

                    if let trailing {
                        Text(trailing)
                            .font(.system(size: 14, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(.lightGreen)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textGray)
                }

                footer
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        isHighlighted
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color.lightGreen.opacity(0.14),
                                        Color.backgroundGray
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.backgroundGray)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.lightGreen.opacity(isHighlighted ? 0.16 : 0.08), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

extension HomeCard where Footer == EmptyView {
    init(
        icon: String,
        label: String,
        title: String,
        trailing: String? = nil,
        isHighlighted: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            label: label,
            title: title,
            trailing: trailing,
            isHighlighted: isHighlighted,
            action: action
        ) {
            EmptyView()
        }
    }
}
