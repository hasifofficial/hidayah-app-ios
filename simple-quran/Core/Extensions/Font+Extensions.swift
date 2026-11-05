//
//  Font+Extensions.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI
import CoreText

extension Font {
    static func amiriBold(size: CGFloat) -> Font {
        .custom("Amiri-Bold", size: size)
    }

    static func amiriRegular(size: CGFloat) -> Font {
        .custom("Amiri-Regular", size: size)
    }

    static func kitabRegular(size: CGFloat) -> Font {
        .custom("Kitab-Regular", size: size)
    }

    static func kitabBold(size: CGFloat) -> Font {
        .custom("Kitab-Bold", size: size)
    }

    /// KFGQPC Douri Uthmanic Script, from `uthmanic-douri-v20.ttf`. Custom
    /// fonts are looked up by PostScript name, not file name.
    static func uthmanicDouri(size: CGFloat) -> Font {
        .custom("KFGQPCDouriUthmanicScript-Regul", size: size)
    }

    /// Draws a surah's calligraphic name from its ligature text; see
    /// `surahNameLigature(for:)`.
    static func surahNameFont(size: CGFloat) -> Font {
        .custom("surah-name-v2", size: size)
    }

    /// The text `surahNameFont` turns into a surah's name: "surah001" to
    /// "surah114". Nil outside that range.
    static func surahNameLigature(for number: Int) -> String? {
        guard (1...114).contains(number) else { return nil }
        return String(format: "surah%03d", number)
    }

    static func loadFontsBundle(bundle: String, fontExtension: String) {
        guard let bundleURL = Bundle.main.url(forResource: bundle, withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL),
              let fontURLs = bundle.urls(forResourcesWithExtension: fontExtension, subdirectory: nil) else { return }

        for url in fontURLs {
            CTFontManagerRegisterFontsForURL(
                url as CFURL,
                .process,
                nil
            )
        }
    }
}
