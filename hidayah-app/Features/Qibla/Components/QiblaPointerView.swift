//
//  QiblaPointerView.swift
//  hidayah-app
//

import SwiftUI

/// The centre of the Qibla screen: a big arrow pointing the way, ringed by
/// dots that glow toward the Qibla, which turns into a pulsing disc once
/// the user is facing it.
struct QiblaPointerView: View {
    let rotation: Double
    let closeness: Double
    let isAligned: Bool

    private let dotCount = 60

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                dotRing(radius: side * 0.44)
                    .opacity(isAligned ? 0 : 1)

                arrow(size: side * 0.5)
                    .opacity(isAligned ? 0 : 1)
                    .scaleEffect(isAligned ? 0.4 : 0.9 + 0.15 * closeness)

                AlignedDisc(diameter: side * 0.62)
                    .opacity(isAligned ? 1 : 0)
                    .scaleEffect(isAligned ? 1 : 0.3)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isAligned)
        .accessibilityHidden(true)
    }

    private func arrow(size: CGFloat) -> some View {
        Image(systemName: "arrow.up")
            .font(.system(size: size, weight: .heavy))
            .foregroundStyle(.white)
            .rotationEffect(.degrees(rotation))
            .animation(.interpolatingSpring(stiffness: 140, damping: 20), value: rotation)
    }

    private func dotRing(radius: CGFloat) -> some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                let angle = Double(index) / Double(dotCount) * 360
                let glow = glow(at: angle)
                Circle()
                    .fill(.white)
                    .frame(width: 4 + 4 * glow, height: 4 + 4 * glow)
                    .opacity(0.18 + 0.82 * glow)
                    .offset(y: -radius)
                    .rotationEffect(.degrees(angle))
            }
        }
        .animation(.interpolatingSpring(stiffness: 140, damping: 20), value: rotation)
    }

    /// 1 for the dot under the arrow, fading to 0 a quarter turn away.
    private func glow(at angle: Double) -> Double {
        let distance = abs(QiblaMath.signedDelta(from: rotation, to: angle))
        return max(0, 1 - distance / 50)
    }
}

/// The white disc with expanding rings shown once aligned.
private struct AlignedDisc: View {
    let diameter: CGFloat

    @State private var pulse = false

    var body: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { ring in
                Circle()
                    .stroke(.white.opacity(0.5), lineWidth: 2)
                    .frame(width: diameter, height: diameter)
                    .scaleEffect(pulse ? 1.6 : 1)
                    .opacity(pulse ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 1.6)
                            .repeatForever(autoreverses: false)
                            .delay(Double(ring) * 0.8),
                        value: pulse
                    )
            }

            Circle()
                .fill(.white)
                .frame(width: diameter, height: diameter)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
        .onAppear { pulse = true }
    }
}
