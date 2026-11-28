//
//  AppRouter.swift
//  hidayah-app
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    var homePath: [AppRoute] = []
    var readingPath: [AppRoute] = []
    var searchPath: [AppRoute] = []
    var trackerPath: [AppRoute] = []
    /// The order of the Al-Mathurat entry a deep link asked to show.
    var mathuratFocusOrder: Int?

    var savedHomePath: [AppRoute] = []
    var savedReadingPath: [AppRoute] = []
    var savedSearchPath: [AppRoute] = []
    var savedTrackerPath: [AppRoute] = []
    var settingsPresented = false
    var whatsNewPresented = false
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
        case .home:
            savedHomePath = homePath
        case .reading:
            savedReadingPath = readingPath
        case .tracker:
            savedTrackerPath = trackerPath
        case .search:
            savedSearchPath = searchPath
        }

        let restoredHomePath = savedHomePath
        let restoredReadingPath = savedReadingPath
        let restoredSearchPath = savedSearchPath
        let restoredTrackerPath = savedTrackerPath

        // NavigationSplitView cannot keep different route types in hidden
        // column stacks at the same time. Clear all paths before switching.
        homePath = []
        readingPath = []
        searchPath = []
        trackerPath = []

        selectedTab = tab

        switch tab {
        case .home:
            homePath = restoredHomePath
            savedHomePath = []
        case .reading:
            readingPath = restoredReadingPath
            savedReadingPath = []
        case .search:
            searchPath = restoredSearchPath
            savedSearchPath = []
        case .tracker:
            trackerPath = restoredTrackerPath
            savedTrackerPath = []
        }
    }

    /// Pushes `route` onto the navigation stack of the selected tab.
    func push(_ route: AppRoute) {
        switch selectedTab {
        case .home:
            homePath.append(route)
        case .reading:
            readingPath.append(route)
        case .tracker:
            trackerPath.append(route)
        case .search:
            searchPath.append(route)
        }
    }

    /// Opens a feature from Explore or the Home shortcuts: screens push onto
    /// the current tab's stack, tab features switch tab.
    func open(_ feature: AppFeature) {
        switch feature.destination {
        case .route(let route):
            push(route)
        case .tab(let tab):
            selectTab(tab)
        }
    }

    /// Switches to the Home tab showing `path` on top of Home, replacing
    /// whatever that tab had open.
    func openHome(_ path: [AppRoute]) {
        selectTab(.home)
        savedHomePath = []
        homePath = path
    }

    /// Switches to the Reading tab showing `path` on top of the Reading
    /// landing page, replacing whatever that tab had open.
    func openReading(_ path: [AppRoute]) {
        selectTab(.reading)
        savedReadingPath = []
        readingPath = path
    }

    /// Opens Al-Mathurat in the Reading tab, scrolled to the entry with
    /// `focusOrder` when given.
    func openMathurat(focusOrder: Int? = nil) {
        openReading([.mathurat])
        mathuratFocusOrder = focusOrder
    }
}

enum AppRoute: Hashable {
    case explore
    case quranList
    case mathurat
    case tasbih
    case qibla
    case rakaat
    case qadaFasting
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
    case homeShortcuts
    case trackerSettings
    case manageCategories
    case widgetGuide
}
