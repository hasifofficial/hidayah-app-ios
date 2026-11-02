//
//  AppRouter.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

@Observable
final class AppRouter {
    var selectedTab: AppTab = .quran
    var quranPath: [AppRoute] = []
    var searchPath: [AppRoute] = []
    var trackerPath: [AppRoute] = []

    var savedQuranPath: [AppRoute] = []
    var savedSearchPath: [AppRoute] = []
    var savedTrackerPath: [AppRoute] = []
    var settingsPresented = false
    var errorMessage: String?

    func selectTab(
        _ tab: AppTab,
        clearingPaths: Bool = true
    ) {
        guard tab != selectedTab else { return }

        guard clearingPaths else {
            selectedTab = tab
            return
        }

        switch selectedTab {
        case .quran:
            savedQuranPath = quranPath
        case .tasbih:
            break
        case .tracker:
            savedTrackerPath = trackerPath
        case .search:
            savedSearchPath = searchPath
        }

        let restoredQuranPath = savedQuranPath
        let restoredSearchPath = savedSearchPath
        let restoredTrackerPath = savedTrackerPath

        // NavigationSplitView cannot keep different route types in hidden
        // column stacks at the same time. Clear all paths before switching.
        quranPath = []
        searchPath = []
        trackerPath = []

        selectedTab = tab

        switch tab {
        case .quran:
            quranPath = restoredQuranPath
            savedQuranPath = []
        case .tasbih:
            break
        case .search:
            searchPath = restoredSearchPath
            savedSearchPath = []
        case .tracker:
            trackerPath = restoredTrackerPath
            savedTrackerPath = []
        }
    }
}

enum AppRoute: Hashable {
    case surahDetail(
        surahNumber: Int,
        title: String?,
        bookmarkedAyah: Int?
    )
    case trackerCalendar
    case trackerAchievements
    case trackerLevels
    case trackerDay(dayKey: String)
    case bookmarkList
}

enum SettingsRoute: Hashable {
    case trackerSettings
    case manageCategories
}
