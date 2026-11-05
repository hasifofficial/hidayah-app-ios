//
//  WhatsNewRelease.swift
//  simple-quran
//
//  The features a release introduces, and whether the reader has seen them.
//

import Foundation

struct WhatsNewFeature: Identifiable, Equatable {
    /// Name of the illustration in the asset catalog.
    let illustration: String
    let titleKey: String
    let bodyKey: String

    var id: String { illustration }
}

struct WhatsNewRelease: Equatable {
    /// Compared with what the reader last saw, so each release shows once.
    let version: String
    let features: [WhatsNewFeature]

    static let current = WhatsNewRelease(
        version: "1.2.1",
        features: [
            WhatsNewFeature(
                illustration: "WhatsNewRefresh",
                titleKey: "whats_new_refresh_title",
                bodyKey: "whats_new_refresh_body"
            ),
            WhatsNewFeature(
                illustration: "WhatsNewMushaf",
                titleKey: "whats_new_mushaf_title",
                bodyKey: "whats_new_mushaf_body"
            ),
            WhatsNewFeature(
                illustration: "WhatsNewMathurat",
                titleKey: "whats_new_mathurat_title",
                bodyKey: "whats_new_mathurat_body"
            ),
            WhatsNewFeature(
                illustration: "WhatsNewTasbih",
                titleKey: "whats_new_tasbih_title",
                bodyKey: "whats_new_tasbih_body"
            ),
            WhatsNewFeature(
                illustration: "WhatsNewWidgets",
                titleKey: "whats_new_widgets_title",
                bodyKey: "whats_new_widgets_body"
            )
        ]
    )

    /// True until the reader has seen this release's screen.
    var isUnseen: Bool {
        Storage.load(key: .whatsNewLastSeenVersion) as? String != version
    }

    func markSeen() {
        Storage.save(.whatsNewLastSeenVersion, version)
    }
}
