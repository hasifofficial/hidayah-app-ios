//
//  LoadAnimation.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

private struct LoadAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let delay: Double
    let offset: CGFloat

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible || reduceMotion ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : offset)
            .onAppear {
                guard !isVisible else { return }

                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(
                        .easeOut(duration: 0.4).delay(delay)
                    ) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func loadAnimation(
        delay: Double = 0,
        offset: CGFloat = 12
    ) -> some View {
        modifier(
            LoadAnimationModifier(
                delay: delay,
                offset: offset
            )
        )
    }
}
