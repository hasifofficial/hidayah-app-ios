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
    /// False in split view, where the sidebar already shows the logo.
    var showsLogo = true

    let onOpenFeature: (AppFeature) -> Void
    let onOpenExplore: () -> Void
    let onOpenTracker: () -> Void
    let onOpenBookmarks: () -> Void
    let onSelectBookmark: (BookmarkedSurah) -> Void
    let onSelectSurah: (SurahListResponse) -> Void
    let onOpenSettings: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var today = Date()
    @State private var containerWidth: CGFloat = 0
    /// The user's chosen shortcuts, watched so Home updates as soon as
    /// they change in Settings.
    @AppStorage(
        Storage.StorageKey.homeShortcuts.rawValue,
        store: Storage.userDefaults
    ) private var shortcutsSetting = ""

    /// The widest the readable column gets on iPad and other wide screens.
    static let columnWidth: CGFloat = 700

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                dateHeader
                    .readableColumn()
                    .padding(.bottom, 10)
                    .loadAnimation(offset: 12)

                exploreShortcuts
                    .readableColumn()
                    .padding(.bottom, 10)
                    .loadAnimation(delay: 0.04, offset: 12)

                trackerCard
                    .readableColumn()
                    .loadAnimation(delay: 0.08, offset: 12)

                quickAccess
                    .loadAnimation(delay: 0.12, offset: 12)

                bookmarksSection
                    .loadAnimation(delay: 0.16, offset: 12)
            }
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.width
        } action: { width in
            containerWidth = width
        }
        .background {
            AppGradientBackground()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsLogo {
                logo
            }

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
        HomeShortcutRow(
            features: HomeShortcuts.decode(shortcutsSetting),
            onOpen: onOpenFeature,
            onOpenAll: onOpenExplore
        )
        .padding(.horizontal, 16)
    }

    // MARK: Cards

    private var trackerCard: some View {
        let total = taskManager.tasks.count
        let completed = taskManager.tasks.filter(\.isCompleted).count
        let stats = taskManager.stats

        return Button(action: onOpenTracker) {
            HStack(spacing: 14) {
                TrackerProgressRing(completed: completed, total: total)

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("tracker_today_tasks_title", comment: ""))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.title)

                    summaryText(
                        fallback: HomeTrackerSummary.message(completed: completed, total: total)
                    )

                    HStack(spacing: 8) {
                        (
                            Text(Image(systemName: "flame.fill"))
                                .foregroundColor(.orange)
                            + Text(" ")
                            + Text(
                                String(
                                    format: NSLocalizedString("home_tracker_streak_format", comment: ""),
                                    stats.currentStreak
                                )
                            )
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textGray)
                        .lineLimit(1)

                        levelPill(stats.level)
                    }
                }
                // Takes exactly the room between the ring and the arrow, so
                // wrapped text can't push the card wider than the screen.
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textGray)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.backgroundGray)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.lightGreen.opacity(0.08), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    /// The level in a pill, in that level's colour from the Levels screen.
    private func levelPill(_ level: Int) -> some View {
        let color = TrackerLevel.color(forLevel: level)

        return HStack(spacing: 3) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 10, weight: .semibold))

            Text(
                String(
                    format: NSLocalizedString("home_tracker_level_format", comment: ""),
                    level
                )
            )
            .font(.system(size: 11, weight: .bold))
            .lineLimit(1)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.14), in: Capsule())
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
        .font(.system(size: 13))
        .foregroundColor(.title)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut(duration: 0.25), value: reflectionModel.message)
        .task(id: trackerSnapshot) {
            await reflectionModel.generate(for: trackerSnapshot)
        }
    }

    // MARK: Quick access

    @ViewBuilder
    private var quickAccess: some View {
        let surahs = quranViewModel.surahs.quickAccessSurahs

        if !surahs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(NSLocalizedString("surah_list_quick_access_title", comment: ""))
                    .readableColumn()

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
                }
                .contentMargins(.horizontal, rowInset, for: .scrollContent)
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
            .readableColumn()

            if bookmarks.isEmpty {
                bookmarksEmptyState
                    .readableColumn()
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
                }
                .contentMargins(.horizontal, rowInset, for: .scrollContent)
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

    /// Side space for the sideways rows, so they run to the screen edges
    /// while their first card lines up with the readable column.
    private var rowInset: CGFloat {
        max(16, (containerWidth - Self.columnWidth) / 2 + 16)
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

private extension View {
    /// Keeps a Home section to the readable column, centred on wide screens.
    func readableColumn() -> some View {
        frame(maxWidth: HomeView.columnWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
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

/// Today's progress as a ring with "done/total" in the middle.
private struct TrackerProgressRing: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 6)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1)))
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)

            Text("\(completed)/\(total)")
                .font(.system(size: 12, weight: .bold))
                .monospacedDigit()
                .foregroundColor(.title)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(9)
        }
        .frame(width: 58, height: 58)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(
                format: NSLocalizedString("home_tracker_progress_format", comment: ""),
                completed,
                total
            )
        )
    }
}
