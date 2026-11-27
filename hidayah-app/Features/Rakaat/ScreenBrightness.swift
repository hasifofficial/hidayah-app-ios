//
//  ScreenBrightness.swift
//  hidayah-app
//

import UIKit

/// The display brightness, so the rakaat screen can dim itself while you
/// pray and put it back afterwards.
@MainActor
protocol ScreenBrightnessControlling: AnyObject {
    /// From 0 to 1.
    var brightness: CGFloat { get set }
}

/// The screen of the app's foreground window scene.
@MainActor
final class DeviceScreenBrightness: ScreenBrightnessControlling {
    private var screen: UIScreen? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .screen
    }

    var brightness: CGFloat {
        get { screen?.brightness ?? 1 }
        set { screen?.brightness = min(max(newValue, 0), 1) }
    }
}
