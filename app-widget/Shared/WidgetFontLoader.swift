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

    static func registerFonts() {
        registerFonts(in: .main)
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
