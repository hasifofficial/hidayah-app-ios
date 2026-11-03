//
//  AppShortcut.swift
//  simple-quran
//

import UIKit

enum AppShortcut: String, CaseIterable {
    case quran = "com.hasifofficial.simple-quran.shortcut.quran"
    case tasbih = "com.hasifofficial.simple-quran.shortcut.tasbih"
    case tracker = "com.hasifofficial.simple-quran.shortcut.tracker"

    var title: String {
        switch self {
        case .quran:
            return NSLocalizedString("shortcut_quran_title", comment: "")
        case .tasbih:
            return NSLocalizedString("shortcut_tasbih_title", comment: "")
        case .tracker:
            return NSLocalizedString("shortcut_tracker_title", comment: "")
        }
    }

    var icon: UIApplicationShortcutIcon {
        switch self {
        case .quran:
            return UIApplicationShortcutIcon(
                templateImageName: "ShortcutQuran"
            )
        case .tasbih:
            return UIApplicationShortcutIcon(
                templateImageName: "ShortcutTasbih"
            )
        case .tracker:
            return UIApplicationShortcutIcon(
                templateImageName: "ShortcutTracker"
            )
        }
    }

    var url: URL {
        switch self {
        case .quran:
            return URL(string: "hidayahapp://inAppDeeplink/quran")!
        case .tasbih:
            return URL(string: "hidayahapp://inAppDeeplink/tasbih")!
        case .tracker:
            return URL(string: "hidayahapp://inAppDeeplink/tracker")!
        }
    }

    var shortcutItem: UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: icon,
            userInfo: nil
        )
    }
}
