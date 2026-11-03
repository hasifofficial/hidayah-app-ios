//
//  WidgetFontLoader.swift
//  app-widget
//

import CoreText
import Foundation

// MARK: - Fonts

@MainActor
enum WidgetFontLoader {
    private static var isRegistered = false

    static func registerFonts() {
        guard !isRegistered else { return }
        isRegistered = true

        let urls = Bundle.main.urls(
            forResourcesWithExtension: "ttf",
            subdirectory: nil
        ) ?? []

        for url in urls {
            CTFontManagerRegisterFontsForURL(
                url as CFURL,
                .process,
                nil
            )
        }
    }
}
