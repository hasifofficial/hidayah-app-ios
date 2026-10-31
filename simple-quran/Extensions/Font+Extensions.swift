//
//  Font+Extensions.swift
//  simple-quran
//

import SwiftUI
import CoreText

extension Font {
    static func amiriBold(size: CGFloat) -> Font {
        .custom("Amiri-Bold", size: size)
    }

    static func amiriBoldItalic(size: CGFloat) -> Font {
        .custom("Amiri-BoldItalic", size: size)
    }

    static func amiriItalic(size: CGFloat) -> Font {
        .custom("Amiri-Italic", size: size)
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
