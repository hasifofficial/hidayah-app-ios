//
//  TrackerLevelColor.swift
//  hidayah-app
//

import SwiftUI

extension TrackerLevel {
    /// One colour per level, moving through the spectrum from the app's
    /// green to gold at the top. Mid tones, so white numbers stay readable
    /// in light and dark mode.
    static let palette: [Color] = [
        Color(red: 0.28, green: 0.72, blue: 0.51), // 1 green
        Color(red: 0.12, green: 0.64, blue: 0.60), // 2 teal
        Color(red: 0.18, green: 0.56, blue: 0.85), // 3 blue
        Color(red: 0.31, green: 0.42, blue: 0.86), // 4 indigo
        Color(red: 0.48, green: 0.36, blue: 0.84), // 5 purple
        Color(red: 0.69, green: 0.31, blue: 0.78), // 6 magenta
        Color(red: 0.85, green: 0.28, blue: 0.49), // 7 pink
        Color(red: 0.91, green: 0.40, blue: 0.24), // 8 orange
        Color(red: 0.88, green: 0.54, blue: 0.12), // 9 amber
        Color(red: 0.72, green: 0.53, blue: 0.04)  // 10 gold
    ]

    /// This level's colour; levels past the palette reuse the last one.
    var color: Color {
        Self.color(forLevel: number)
    }

    static func color(forLevel number: Int) -> Color {
        palette[min(max(number, 1), palette.count) - 1]
    }
}
