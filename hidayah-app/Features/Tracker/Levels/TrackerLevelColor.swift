//
//  TrackerLevelColor.swift
//  hidayah-app
//

import SwiftUI

extension TrackerLevel {
    /// The level colours, from `LevelColor` so the Watch app uses the same.
    static var palette: [Color] { LevelColor.palette }

    /// This level's colour; levels past the palette reuse the last one.
    var color: Color {
        Self.color(forLevel: number)
    }

    static func color(forLevel number: Int) -> Color {
        LevelColor.forLevel(number)
    }
}
