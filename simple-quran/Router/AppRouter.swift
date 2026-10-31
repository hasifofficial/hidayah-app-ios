//
//  AppRouter.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 31/10/2026.
//

import Foundation

@Observable
final class AppRouter {
    var selectedTab: AppTab = .quran
    var quranPath: [AppRoute] = []
    var bookmarkPath: [AppRoute] = []
    var searchPath: [AppRoute] = []
    var settingsPresented = false
    var errorMessage: String?
}

enum AppRoute: Hashable {
    case surahDetail(
        surahNumber: Int,
        title: String?,
        bookmarkedAyah: Int?
    )
}

enum SettingsRoute: Hashable {
    case trackerSettings
    case manageCategories
}
