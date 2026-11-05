//
//  Constants.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation

struct Constants {
    static let feedbackEmail = "mohammadhasifafiq@gmail.com"
    static let websiteUrl = "https://www.hasifofficial.com"
    static let privacyUrl = "https://www.hasifofficial.com/hidayah/privacy_policy.html"
    static let termConditionUrl = "https://www.hasifofficial.com/hidayah/term_condition.html"
    
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
