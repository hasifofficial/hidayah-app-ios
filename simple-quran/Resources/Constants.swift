//
//  Constants.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/14/21.
//

import Foundation

struct Constants {
    static let feedbackEmail = "mohammadhasifafiq@gmail.com"
    static let websiteUrl = "https://www.hasifofficial.com"
    static let privacyUrl = "https://www.hasifofficial.com/hidayah/privacy_policy.html"
    static let termConditionUrl = "https://www.hasifofficial.com/hidayah/term_condition.html"
    
    static func getLanguageFromCode(code: String) -> String {
        switch code.lowercased() {
        case "ar":
            return "Arabic"
        case "az":
            return "Azerbaijani"
        case "ba":
            return "Bashkir"
        case "bg":
            return "Bulgarian"
        case "bn":
            return "Bengali"
        case "bs":
            return "Bosnian"
        case "cs":
            return "Czech"
        case "de":
            return "German"
        case "dv":
            return "Divehi"
        case "en":
            return "English"
        case "es":
            return "Spanish"
        case "fa":
            return "Persian"
        case "fr":
            return "French"
        case "ha":
            return "Hausa"
        case "hi":
            return "Hindi"
        case "id":
            return "Indonesian"
        case "it":
            return "Italian"
        case "ja":
            return "Japanese"
        case "ko":
            return "Korean"
        case "ku":
            return "Kurdish"
        case "ml":
            return "Malayalam"
        case "ms":
            return "Malay"
        case "nl":
            return "Dutch"
        case "no":
            return "Norwegian"
        case "pl":
            return "Polish"
        case "pt":
            return "Portuguese"
        case "ro":
            return "Romanian"
        case "ru":
            return "Russian"
        case "sd":
            return "Sindhi"
        case "so":
            return "Somali"
        case "sq":
            return "Albanian"
        case "sv":
            return "Swedish"
        case "si":
            return "Sinhala"
        case "sw":
            return "Swahili"
        case "ta":
            return "Tamil"
        case "tg":
            return "Tajik"
        case "th":
            return "Thai"
        case "tr":
            return "Turkish"
        case "tt":
            return "Tatar"
        case "ug":
            return "Uighur"
        case "ur":
            return "Urdu"
        case "uz":
            return "Uzbek"
        case "zh":
            return "Chinese"
        default:
            return "Unknown"
        }
    }
}
