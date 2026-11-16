//
//  AppGradientBackground.swift
//  simple-quran
//

import SwiftUI

/// The soft green full-screen gradient behind Home, Explore and Tasbih.
struct AppGradientBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground

            LinearGradient(
                colors: [
                    Color.lightGreen.opacity(0.18),
                    Color.lightGreen.opacity(0.06),
                    Color.appBackground,
                    Color.backgroundGray.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.lightGreen.opacity(0.13))
                .frame(width: 320, height: 320)
                .blur(radius: 45)
                .offset(y: -120)
        }
        .ignoresSafeArea()
    }
}
