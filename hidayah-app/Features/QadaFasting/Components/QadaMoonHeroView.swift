//
//  QadaMoonHeroView.swift
//  hidayah-app
//

import SwiftUI

/// The top of the Qada screen: a night sky whose moon waxes from a thin
/// crescent to full as the owed fasts are made up.
struct QadaMoonHeroView: View {
    /// 0 is a new moon, 1 a full moon.
    let phase: Double
    let remaining: String
    let remainingLabel: String
    let summary: String
    let deadline: QadaFastingViewModel.Deadline?
    let isComplete: Bool
    /// Bumped each time a fast is logged, to play the sparkle burst.
    let celebration: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            QadaNightSky(twinkles: !reduceMotion)

            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 18) {
                    ZStack {
                        QadaMoonView(phase: phase, glows: isComplete)
                            .frame(width: 104, height: 104)

                        QadaSparkleBurst(trigger: celebration, enabled: !reduceMotion)
                    }
                    .frame(width: 120, height: 120)
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        if isComplete {
                            Text(summary)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(remaining)
                                    .font(.system(size: 46, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .contentTransition(.numericText())

                                Text(remainingLabel)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.75))
                            }

                            Text(summary)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(QadaPalette.moonLight)
                        }
                    }
                    .accessibilityElement(children: .combine)

                    Spacer(minLength: 0)
                }

                if let deadline {
                    deadlineStrip(deadline)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, deadline == nil ? 18 : 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: QadaPalette.nightBottom.opacity(0.35), radius: 18, y: 10)
    }

    /// One line across the card: when the next Ramadan begins.
    private func deadlineStrip(_ deadline: QadaFastingViewModel.Deadline) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(QadaPalette.moonLight)

            // One phrase, with the countdown picked out in bold.
            (
                Text(deadline.label + " ")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                + Text(deadline.countdown)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            )
            .lineLimit(1)

            Spacer(minLength: 0)
        }
        .minimumScaleFactor(0.85)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Fixed night colours: the hero stays a night sky in light and dark mode.
enum QadaPalette {
    static let nightTop = Color(red: 0.05, green: 0.20, blue: 0.16)
    static let nightBottom = Color(red: 0.07, green: 0.36, blue: 0.27)
    static let moonLight = Color(red: 1.0, green: 0.88, blue: 0.56)
    static let moonDeep = Color(red: 0.95, green: 0.70, blue: 0.22)
}

private struct QadaNightSky: View {
    let twinkles: Bool

    /// Star positions as fractions of the card, with size and a delay so
    /// they don't twinkle together. All sit above the deadline strip, where
    /// a star showing through reads like an accent on the text.
    private static let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0.08, 0.14, 2.5, 0.0), (0.06, 0.62, 2, 0.6), (0.42, 0.10, 3, 1.1),
        (0.58, 0.64, 2, 0.3), (0.68, 0.20, 2.5, 1.5), (0.82, 0.08, 2, 0.9),
        (0.94, 0.42, 3, 0.4), (0.80, 0.60, 2, 1.8), (0.36, 0.56, 1.5, 1.3),
        (0.97, 0.16, 2, 0.7)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [QadaPalette.nightTop, QadaPalette.nightBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(QadaPalette.moonLight.opacity(0.10))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)
                    .position(x: 70, y: proxy.size.height / 2)

                ForEach(Self.stars.indices, id: \.self) { index in
                    let star = Self.stars[index]
                    TwinklingStar(size: star.size, delay: star.delay, twinkles: twinkles)
                        .position(
                            x: proxy.size.width * star.x,
                            y: proxy.size.height * star.y
                        )
                }
            }
        }
    }
}

private struct TwinklingStar: View {
    let size: CGFloat
    let delay: Double
    let twinkles: Bool

    @State private var isDim = false

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: size, height: size)
            .opacity(isDim ? 0.25 : 0.9)
            .onAppear {
                guard twinkles else { return }
                withAnimation(
                    .easeInOut(duration: 1.6)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    isDim = true
                }
            }
    }
}

/// A moon lit from the right: a shadow disc slides off the lit disc as
/// `phase` grows, so the crescent widens into a full moon.
struct QadaMoonView: View {
    let phase: Double
    var glows = false

    /// Keeps a sliver showing on a new moon, so there's always a moon.
    private var visiblePhase: Double {
        0.12 + 0.88 * min(max(phase, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                // The unlit moon, faintly visible.
                Circle()
                    .fill(.white.opacity(0.08))

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [QadaPalette.moonLight, QadaPalette.moonDeep],
                                center: UnitPoint(x: 0.65, y: 0.35),
                                startRadius: 2,
                                endRadius: size * 0.7
                            )
                        )

                    Circle()
                        .fill(.black)
                        .offset(x: -size * visiblePhase * 1.02)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .clipShape(Circle())
                .shadow(color: QadaPalette.moonLight.opacity(glows ? 0.8 : 0.35), radius: glows ? 22 : 10)
            }
            .frame(width: size, height: size)
            .animation(.spring(response: 0.8, dampingFraction: 0.75), value: visiblePhase)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Little stars flying out from the moon when a fast is logged.
private struct QadaSparkleBurst: View {
    let trigger: Int
    let enabled: Bool

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                let angle = Double(index) / 10 * 2 * .pi
                Image(systemName: "sparkle")
                    .font(.system(size: index.isMultiple(of: 2) ? 14 : 9, weight: .bold))
                    .foregroundColor(QadaPalette.moonLight)
                    .keyframeAnimator(
                        initialValue: SparkleFrame(),
                        trigger: trigger
                    ) { view, frame in
                        view
                            .offset(
                                x: cos(angle) * frame.distance,
                                y: sin(angle) * frame.distance
                            )
                            .scaleEffect(frame.scale)
                            .opacity(frame.opacity)
                    } keyframes: { _ in
                        KeyframeTrack(\.distance) {
                            CubicKeyframe(enabled ? 70 : 0, duration: 0.7)
                        }
                        KeyframeTrack(\.scale) {
                            CubicKeyframe(1.2, duration: 0.25)
                            CubicKeyframe(0.2, duration: 0.45)
                        }
                        KeyframeTrack(\.opacity) {
                            CubicKeyframe(enabled ? 1 : 0, duration: 0.15)
                            CubicKeyframe(0, duration: 0.55)
                        }
                    }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SparkleFrame {
    var distance: CGFloat = 0
    var scale: CGFloat = 0.2
    var opacity: Double = 0
}
