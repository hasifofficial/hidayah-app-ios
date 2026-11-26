//
//  RakaatPrayer.swift
//  hidayah-app
//

import Foundation

/// A prayer the rakaat counter can follow, with how many rakaat it has.
/// Shared with the Watch, so it uses Foundation only.
enum RakaatPrayer: Codable, Hashable, Identifiable {
    case fajr
    case dhuhr
    case asr
    case maghrib
    case isha
    /// Two rakaat of sunnah or nafl.
    case sunnah
    case witir
    /// Any number of rakaat, clamped to `customRange`.
    case custom(rakaat: Int)

    static let customRange = 1...12

    /// The choices offered in the picker, in order. Custom is offered
    /// separately with its own stepper.
    static let presets: [RakaatPrayer] = [.fajr, .dhuhr, .asr, .maghrib, .isha, .sunnah, .witir]

    var id: String {
        switch self {
        case .custom(let rakaat):
            return "custom-\(rakaat)"
        default:
            return nameKey
        }
    }

    var rakaatCount: Int {
        switch self {
        case .fajr, .sunnah:
            return 2
        case .maghrib, .witir:
            return 3
        case .dhuhr, .asr, .isha:
            return 4
        case .custom(let rakaat):
            return min(max(rakaat, Self.customRange.lowerBound), Self.customRange.upperBound)
        }
    }

    /// The rakaat after which you sit for tashahhud: the second (when the
    /// prayer is longer) and the last.
    var tashahhudRakaat: [Int] {
        let count = rakaatCount
        return count >= 3 ? [2, count] : [count]
    }

    var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

    var nameKey: String {
        switch self {
        case .fajr: return "rakaat_prayer_fajr"
        case .dhuhr: return "rakaat_prayer_dhuhr"
        case .asr: return "rakaat_prayer_asr"
        case .maghrib: return "rakaat_prayer_maghrib"
        case .isha: return "rakaat_prayer_isha"
        case .sunnah: return "rakaat_prayer_sunnah"
        case .witir: return "rakaat_prayer_witir"
        case .custom: return "rakaat_prayer_custom"
        }
    }

    var displayName: String {
        NSLocalizedString(nameKey, comment: "")
    }
}
