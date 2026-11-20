//
//  HomeShortcuts.swift
//  simple-quran
//

import Foundation

/// The features the user pins as shortcuts on Home, before the "All" tile.
/// Stored as comma-separated `AppFeature` raw values so Home can watch the
/// setting with `@AppStorage`.
enum HomeShortcuts {
    /// How many shortcuts fit beside the "All" tile.
    static let limit = 3
    static let defaults: [AppFeature] = [.quran, .mathurat, .tasbih]

    /// The shortcuts in `raw`, in order. Unknown or repeated features are
    /// dropped (a feature removed in a later version, say), and the result
    /// falls back to the defaults when nothing usable is left.
    static func decode(_ raw: String?) -> [AppFeature] {
        var features: [AppFeature] = []
        for value in (raw ?? "").split(separator: ",") {
            guard let feature = AppFeature(rawValue: String(value)),
                  !features.contains(feature) else { continue }
            features.append(feature)
        }
        let usable = Array(features.prefix(limit))
        return usable.isEmpty ? defaults : usable
    }

    static func encode(_ features: [AppFeature]) -> String {
        features.map(\.rawValue).joined(separator: ",")
    }

    static func load(from store: UserDefaults? = Storage.userDefaults) -> [AppFeature] {
        decode(store?.string(forKey: Storage.StorageKey.homeShortcuts.rawValue))
    }

    static func save(_ features: [AppFeature], to store: UserDefaults? = Storage.userDefaults) {
        store?.set(encode(features), forKey: Storage.StorageKey.homeShortcuts.rawValue)
    }
}
