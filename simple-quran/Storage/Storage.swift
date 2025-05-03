//
//  Storage.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/6/21.
//

import Foundation

class Storage {
    static let userDefaults = UserDefaults(suiteName: "group.com.hasifofficial.simple-quran")

    enum StorageKey: String, CaseIterable {
        case bookmarkRecitations
        case selectedRecitation
        case selectedTranslation
        case allowKahfReminder
        case trackerContext
        case widgetContext
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
