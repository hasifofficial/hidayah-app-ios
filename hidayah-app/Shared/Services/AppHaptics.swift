//
//  AppHaptics.swift
//  hidayah-app
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import UIKit

@MainActor
enum AppHaptics {
    private static let impact = UIImpactFeedbackGenerator(style: .light)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap() {
        impact.prepare()
        impact.impactOccurred(intensity: 0.8)
    }

    /// A firm tap whose strength follows `intensity` (0...1).
    static func impact(intensity: Double) {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: CGFloat(min(max(intensity, 0), 1)))
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func success() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }
}
