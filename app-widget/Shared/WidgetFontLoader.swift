//
//  WidgetFontLoader.swift
//  app-widget
//

import CoreText
import Foundation

// MARK: - Fonts

@MainActor
enum WidgetFontLoader {
    /// Set once the first registration ran. Internal so tests can reset it.
    static var isRegistered = false

    /// The widget's fonts sit in `Fonts.bundle`, not at the top of the
    /// extension, so look there.
    static func registerFonts() {
        registerFonts(in: fontsBundle(in: .main) ?? .main)
    }

    static func fontsBundle(in bundle: Bundle) -> Bundle? {
        bundle.url(forResource: "Fonts", withExtension: "bundle")
            .flatMap(Bundle.init(url:))
    }

    static func registerFonts(in bundle: Bundle) {
        guard !isRegistered else { return }
        isRegistered = true

        for url in fontURLs(in: bundle) {
            CTFontManagerRegisterFontsForURL(
                url as CFURL,
                .process,
                nil
            )
        }
    }

    static func fontURLs(in bundle: Bundle) -> [URL] {
        bundle.urls(
            forResourcesWithExtension: "ttf",
            subdirectory: nil
        ) ?? []
    }
}
