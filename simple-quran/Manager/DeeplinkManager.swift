//
//  DeeplinkManager.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/3/25.
//

import Foundation

class DeeplinkManager: NSObject {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router

        super.init()
    }

    enum DeepLink {
        case quran
        case quranDetail(surahNumber: Int, selectedAyahNumber: Int?)
        case bookmark
        case tracker
        
        static func build(from url: URL) -> DeepLink? {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let host = components.host else { return nil }
            
            let pathComponents = components.path.components(separatedBy: "/").filter { !$0.isEmpty }
            
            switch host {
            case "inAppDeeplink":
                return handleTabDeeplink(pathComponents: pathComponents)
            default:
                return nil
            }
        }
        
        private static func handleTabDeeplink(pathComponents: [String]) -> DeepLink? {
            guard let firstComponent = pathComponents.first else { return nil }

            switch firstComponent {
            case "quran":
                var selectedAyahNumber: Int?

                if pathComponents.count > 1,
                   let surahNumber = Int(pathComponents[1]) {
                    if let ayahNumber = pathComponents[safe: 2] {
                        selectedAyahNumber = Int(ayahNumber)
                    }

                    return .quranDetail(
                        surahNumber: surahNumber,
                        selectedAyahNumber: selectedAyahNumber
                    )
                }
                return .quran
            case "bookmark":
                return .bookmark
            case "tracker":
                return .tracker
            default:
                return nil
            }
        }
    }

    @discardableResult
    func handleDeepLink(
        url: URL
    ) -> Bool {
        #if DEBUG
        print("🔗 Deeplink received: \(url.absoluteString)")
        #endif

        guard let deepLink = DeepLink.build(from: url) else {
            #if DEBUG
            print("⚠️ Deeplink could not be parsed")
            #endif
            return false
        }

        router.settingsPresented = false

        switch deepLink {
        case .quran:
            router.selectTab(.quran)
        case .bookmark:
            router.selectTab(.quran)
            router.quranPath = [.bookmarkList]
        case .tracker:
            router.selectTab(.tracker)
        case .quranDetail(let surahNumber, let selectedAyahNumber):
            router.selectTab(.quran)
            router.quranPath = [
                .surahDetail(
                    surahNumber: surahNumber,
                    title: nil,
                    bookmarkedAyah: selectedAyahNumber
                )
            ]
        }

        #if DEBUG
        print("✅ Deeplink handled")
        #endif

        return true
    }
}
