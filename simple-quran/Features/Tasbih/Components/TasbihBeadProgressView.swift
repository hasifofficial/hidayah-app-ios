//
//  TasbihBeadProgressView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct TasbihBeadProgressView: View {
    let progress: Double
    let count: Int
    let target: Int

    @State private var highlightedBead: Int?
    @State private var isPulsing = false

    private let beadCount = 9
    private let activeColor = Color.lightGreen
    private let highlightColor = Color(red: 0.82, green: 0.69, blue: 0.38)

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            let filledCount = min(
                beadCount,
                Int(ceil(progress * Double(beadCount)))
            )

            ZStack {
                ForEach(0..<beadCount, id: \.self) { index in
                    let t = Double(index) / Double(beadCount - 1)
                    let point = beadPoint(
                        t: t,
                        width: width,
                        height: height
                    )
                    let filled = index >= beadCount - filledCount
                    let isHighlighted = highlightedBead == index

                    Circle()
                        .fill(
                            isHighlighted
                                ? highlightColor
                                : (filled
                                    ? activeColor
                                    : Color.lightGreen.opacity(0.16))
                        )
                        .frame(
                            width: isHighlighted ? 36 : 30,
                            height: isHighlighted ? 36 : 30
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    isHighlighted
                                        ? highlightColor.opacity(0.9)
                                        : (filled
                                            ? activeColor.opacity(0.9)
                                            : Color.textGray.opacity(0.08)),
                                    lineWidth: 1
                                )
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    highlightColor.opacity(
                                        isHighlighted ? 0.45 : 0
                                    ),
                                    lineWidth: 2
                                )
                                .scaleEffect(isHighlighted ? 1.45 : 1)
                        }
                        .shadow(
                            color: isHighlighted
                                ? highlightColor.opacity(0.55)
                                : (filled ? activeColor.opacity(0.25) : .clear),
                            radius: isHighlighted ? 12 : 5
                        )
                        .scaleEffect(
                            isHighlighted && isPulsing ? 1.16 : 1
                        )
                        .position(point)
                        .animation(
                            .spring(
                                response: 0.28,
                                dampingFraction: 0.55
                            ),
                            value: highlightedBead
                        )
                        .animation(
                            .spring(
                                response: 0.2,
                                dampingFraction: 0.5
                            ),
                            value: isPulsing
                        )
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: filled
                        )
                }

                if let highlightedBead {
                    let t = Double(highlightedBead)
                        / Double(beadCount - 1)
                    let point = beadPoint(
                        t: t,
                        width: width,
                        height: height
                    )

                    Circle()
                        .fill(highlightColor.opacity(0.30))
                        .frame(width: 44, height: 44)
                        .blur(radius: 9)
                        .position(point)
                        .allowsHitTesting(false)
                        .animation(
                            .spring(
                                response: 0.32,
                                dampingFraction: 0.7
                            ),
                            value: highlightedBead
                        )
                }
            }
        }
        .onChange(of: count) { _, newCount in
            animateBead(for: newCount)
        }
    }

    private func animateBead(for newCount: Int) {
        guard newCount > 0, target > 0 else {
            highlightedBead = nil
            isPulsing = false
            return
        }

        let filledCount = min(
            beadCount,
            Int(
                ceil(
                    (Double(newCount) / Double(target))
                        * Double(beadCount)
                )
            )
        )
        let index = max(0, beadCount - filledCount)

        highlightedBead = index
        isPulsing = false

        withAnimation(
            .spring(response: 0.22, dampingFraction: 0.45)
        ) {
            isPulsing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.2)) {
                if highlightedBead == index {
                    isPulsing = false
                }
            }
        }
    }

    private func beadPoint(
        t: Double,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let x = width * (0.07 + 0.86 * t)
        let curve = pow((t - 0.5) * 2, 2)
        let y = height * (0.30 + 0.52 * curve)
        return CGPoint(x: x, y: y)
    }
}

