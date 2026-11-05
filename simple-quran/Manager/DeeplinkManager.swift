//
//  DeeplinkManager.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/3/25.
//

import UIKit

class DeeplinkManager: NSObject {
    let surahService: SurahService

    init(
        surahService: SurahService
    ) {
        self.surahService = surahService
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
            guard !pathComponents.isEmpty else { return nil }
            
            switch pathComponents[0] {
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

    func handleDeepLink(
        url: URL,
    ) -> Bool {
        guard let deepLink = DeepLink.build(from: url) else { return false }
        
        switch deepLink {
        case .quran:
            return navigateToTab(index: 0)
        case .bookmark:
            return navigateToTab(index: 1)
        case .tracker:
            return navigateToTab(index: 2)
        case .quranDetail(let surahNumber, let selectedAyahNumber):
            let tabSelected = navigateToTab(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigateToSurahDetail(
                    surahNumber: surahNumber,
                    selectedAyahNumber: selectedAyahNumber
                )
            }
            return tabSelected
        }
    }
    
    private func navigateToTab(index: Int) -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController as? RootViewController,
              index < (rootVC.viewControllers?.count ?? 0) else {
            return false
        }
        
        rootVC.selectedIndex = index
        return true
    }

    private func navigateToSurahDetail(
        surahNumber: Int,
        selectedAyahNumber: Int? = nil,
    ) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController as? RootViewController,
              let navigationController = rootVC.viewControllers?[rootVC.selectedIndex] as? UINavigationController else {
            return
        }
        
        navigationController.popToRootViewController(animated: false)
        
        let vc = SurahDetailViewController<SurahDetailViewModel>(
            surahService: surahService,
            bookmarkedAyah: selectedAyahNumber,
            scrollToSpecificAyah: selectedAyahNumber != nil
        )
        vc.viewModel.selectedSurahNo.send(surahNumber)
        
        navigationController.pushViewController(vc, animated: true)
    }
}
