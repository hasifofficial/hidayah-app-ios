//
//  Category.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import Foundation

enum DefaultCategory: String, CaseIterable, Identifiable, Codable {
    case morning = "Upon Waking Up"
    case tahajjud = "Tahajjud Companions"
    case fajr = "Fajr (Dawn Prayer)"
    case recitation = "Recitation"
    case dhuha = "Dhuha"
    case dhuhr = "Dhuhr (Noon Prayer)"
    case asr = "Asr (Afternoon Prayer)"
    case maghrib = "Maghrib (Sunset Prayer)"
    case isha = "Isha (Night Prayer)"
    case bedtime = "Before Sleeping"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .morning: return "sunrise"
        case .tahajjud: return "moon.stars"
        case .fajr: return "sun.max"
        case .recitation: return "book"
        case .dhuha: return "sun.haze"
        case .dhuhr: return "sun.min"
        case .asr: return "sun.dust"
        case .maghrib: return "sunset"
        case .isha: return "moon"
        case .bedtime: return "bed.double"
        }
    }
}

struct CustomCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder"
    ) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

enum Category: Identifiable, Hashable, Codable {
    case `default`(DefaultCategory)
    case custom(CustomCategory)
    
    var id: String {
        switch self {
        case .default(let defaultTime):
            return "default_\(defaultTime.id)"
        case .custom(let custom):
            return "custom_\(custom.id.uuidString)"
        }
    }
    
    var name: String {
        switch self {
        case .default(let defaultTime):
            return defaultTime.rawValue
        case .custom(let custom):
            return custom.name
        }
    }
    
    var icon: String {
        switch self {
        case .default(let defaultTime):
            return defaultTime.icon
        case .custom(let custom):
            return custom.icon
        }
    }
}
