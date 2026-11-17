//
//  QiblaMessageView.swift
//  hidayah-app
//

import SwiftUI

/// A centred icon, message and optional button for the states before the
/// compass can point: permission, denied, no compass, locating.
struct QiblaMessageView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.bottom, 6)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(message)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(.white, in: Capsule())
                }
                .padding(.top, 10)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
}

/// The scattered, gently pulsing dots shown while the compass is still
/// finding the user's location.
struct QiblaSearchingDots: View {
    @State private var phase = false

    private let dots: [(x: CGFloat, y: CGFloat, delay: Double)] = (0..<36).map { index in
        let angle = Double(index) * 2.399963 // golden angle
        let radius = sqrt(Double(index) / 36)
        return (
            CGFloat(cos(angle) * radius),
            CGFloat(sin(angle) * radius),
            Double(index % 6) * 0.18
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let half = min(proxy.size.width, proxy.size.height) * 0.42
            ZStack {
                ForEach(dots.indices, id: \.self) { index in
                    let dot = dots[index]
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                        .opacity(phase ? 0.85 : 0.15)
                        .scaleEffect(phase ? 1.2 : 0.7)
                        .offset(x: dot.x * half, y: dot.y * half)
                        .animation(
                            .easeInOut(duration: 1.1)
                                .repeatForever()
                                .delay(dot.delay),
                            value: phase
                        )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear { phase = true }
        .accessibilityHidden(true)
    }
}
