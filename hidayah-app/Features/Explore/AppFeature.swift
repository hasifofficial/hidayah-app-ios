//
//  AppFeature.swift
//  hidayah-app
//

import Foundation

/// The main features listed on the Explore page, in display order. To add
/// a feature, add a case here with its text, icon and destination; Explore
/// picks it up from `allCases`.
enum AppFeature: String, CaseIterable, Identifiable {
    case quran
    case mathurat
    case tasbih
    case qibla
    case rakaat
    case qada
    case tracker

    var id: String { rawValue }

    /// Where a feature opens: pushed onto the current tab's stack, or a tab
    /// of its own.
    enum Destination: Equatable {
        case route(AppRoute)
        case tab(AppTab)
    }

    var title: String {
        switch self {
        case .quran:
            return NSLocalizedString("surah_list_header_title", comment: "")
        case .mathurat:
            return NSLocalizedString("mathurat_header_title", comment: "")
        case .tasbih:
            return NSLocalizedString("tasbih_tab_title", comment: "")
        case .qibla:
            return NSLocalizedString("qibla_header_title", comment: "")
        case .rakaat:
            return NSLocalizedString("rakaat_header_title", comment: "")
        case .qada:
            return NSLocalizedString("qada_header_title", comment: "")
        case .tracker:
            return NSLocalizedString("tracker_list_header_title", comment: "")
        }
    }

    /// A shorter name for tight spaces such as the Home shortcut tiles.
    var shortTitle: String {
        switch self {
        case .tracker:
            return NSLocalizedString("tracker_list_tab_bar_title", comment: "")
        default:
            return title
        }
    }

    var subtitle: String {
        NSLocalizedString("explore_\(rawValue)_subtitle", comment: "")
    }

    var icon: String {
        switch self {
        case .quran:
            return "book.fill"
        case .mathurat:
            return "sun.horizon.fill"
        case .tasbih:
            return "circle.grid.3x3.fill"
        case .qibla:
            return "location.north.circle.fill"
        case .rakaat:
            return "figure.mind.and.body"
        case .qada:
            return "moon.stars.fill"
        case .tracker:
            return "checklist.checked"
        }
    }

    /// An asset image used instead of `icon`: Tasbih uses its bead icon.
    var assetIcon: String? {
        switch self {
        case .tasbih:
            return "TasbihIconFill"
        default:
            return nil
        }
    }

    /// A 3D-style illustration drawn for this feature.
    var illustration: String {
        "Illustration\(rawValue.prefix(1).uppercased())\(rawValue.dropFirst())"
    }

    /// The illustration for the "All" tile that opens Explore.
    static let allIllustration = "IllustrationAll"

    var destination: Destination {
        switch self {
        case .quran:
            return .route(.quranList)
        case .mathurat:
            return .route(.mathurat)
        case .tasbih:
            return .route(.tasbih)
        case .qibla:
            return .route(.qibla)
        case .rakaat:
            return .route(.rakaat)
        case .qada:
            return .route(.qadaFasting)
        case .tracker:
            return .tab(.tracker)
        }
    }
}
