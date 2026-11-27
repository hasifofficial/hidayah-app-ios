//
//  Constants.swift
//  hidayah-app
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

struct Constants {
    static let feedbackEmail = "mohammadhasifafiq@gmail.com"
    static let websiteUrl = "https://hidayah.hasifofficial.com"
    static let privacyUrl = "https://hidayah.hasifofficial.com/privacy_policy.html"
    static let termConditionUrl = "https://hidayah.hasifofficial.com/term_condition.html"
    
    static func getLanguageFromCode(code: String) -> String {
        guard !code.isEmpty else {
            return NSLocalizedString(
                "quran_language_unknown",
                comment: ""
            )
        }

        if let name = Locale.current.localizedString(
            forLanguageCode: code.lowercased()
        ) {
            return name
        }

        return NSLocalizedString(
            "quran_language_unknown",
            comment: ""
        )
    }
}
