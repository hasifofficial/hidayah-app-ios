//
//  Storage.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

enum AppEnvironment {
    /// True when the process hosts unit tests. Shared instances then use
    /// isolated storage so tests never read or overwrite the user's data.
    static let isRunningUnitTests = ProcessInfo.processInfo
        .environment["XCTestConfigurationFilePath"] != nil
}

class Storage {
    // UserDefaults is documented as thread-safe but is not marked Sendable.
    nonisolated(unsafe) static let userDefaults = UserDefaults(
        suiteName: AppEnvironment.isRunningUnitTests
            ? "com.hasifofficial.simple-quran.tests"
            : "group.com.hasifofficial.simple-quran"
    )

    enum StorageKey: String, CaseIterable {
        case selectedRecitation
        case selectedTranslation
        case allowKahfReminder
        case allowTrackerCheerleader
        case trackerCheerState
        case widgetContext
        case quranArabicFontSize
        case quranShowTranslation
        case quranReadingMode
        case mushafShowsSpread
        case trackerActiveDayKey
        case trackerStartDayKey
        case hasMigratedToSwiftData
    }

    static func save(_ key: StorageKey, _ value: Any) {
        userDefaults?.set(value, forKey: key.rawValue)
    }

    static func loadObject<T>(key: StorageKey) -> T? where T: Decodable {
        if let data = userDefaults?.value(forKey: key.rawValue) as? Data {
            do {
                return try JSONDecoder().decode(T.self, from: data) as T
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    static func load(key: StorageKey) -> Any? {
        return userDefaults?.value(forKey: key.rawValue)
    }
    
    static func delete(_ key: StorageKey) {
        userDefaults?.removeObject(forKey: key.rawValue)
    }
}
