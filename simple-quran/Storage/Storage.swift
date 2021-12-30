//
//  Storage.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/6/21.
//

import Foundation

class Storage {
    enum StorageKey: String, CaseIterable {
        case selectedRecitation
        case selectedTranslation
        case allowKahfReminder
        case calculationMethod
        case mazhab
        case fajrTune
        case sunriseTune
        case dhuhrTune
        case asrTune
        case maghribTune
        case ishaTune
    }
    
    static func save(_ key: StorageKey, _ value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func loadObject<T>(key: StorageKey) -> T? where T: Decodable {
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data {
            do {
                return try JSONDecoder().decode(T.self, from: data) as T
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
    
    static func load(key: StorageKey) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }
    
    static func delete(_ key: StorageKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    static func clear() {
        Storage.delete(.selectedRecitation)
        Storage.delete(.selectedTranslation)
        Storage.delete(.allowKahfReminder)
        Storage.delete(.calculationMethod)
        Storage.delete(.mazhab)
        Storage.delete(.fajrTune)
        Storage.delete(.sunriseTune)
        Storage.delete(.dhuhrTune)
        Storage.delete(.asrTune)
        Storage.delete(.maghribTune)
        Storage.delete(.ishaTune)
    }
}
