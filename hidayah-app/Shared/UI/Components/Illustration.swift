//
//  Illustration.swift
//  hidayah-app
//

import SwiftUI

/// Names of the 3D-style illustrations in `Assets.xcassets/Illustrations`
/// that are not tied to one feature. Feature illustrations come from
/// `AppFeature.illustration`; the drawing sources are in
/// `design/illustrations`.
enum Illustration {
    /// A closed mushaf, small enough for the surah cards.
    static let quranClosed = "IllustrationQuranClosed"
    static let bookmark = "IllustrationBookmark"
    static let mathuratEvening = "IllustrationMathuratEvening"
    static let calendar = "IllustrationCalendar"
    static let search = "IllustrationSearch"
    /// The Kaaba, shown on the Qibla screen once you face it. A vector, so
    /// it stays sharp at the size of the disc.
    static let kaaba = "IllustrationKaaba"
    /// Rakaat counter: where to place the phone on the mat, and the
    /// forehead coming down over it in sujood. Vectors, wider than square.
    static let rakaatPlacement = "IllustrationRakaatPlacement"
    static let rakaatSujood = "IllustrationRakaatSujood"

    /// The size of an illustration in an empty state.
    static let emptyStateSize: CGFloat = 96
}

/// An illustration from the asset catalogue at a square `size`. It is
/// decorative, so VoiceOver skips it.
struct IllustrationImage: View {
    let name: String
    let size: CGFloat

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
