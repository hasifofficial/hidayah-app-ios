//
//  AppHaptics.swift
//  simple-quran
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
