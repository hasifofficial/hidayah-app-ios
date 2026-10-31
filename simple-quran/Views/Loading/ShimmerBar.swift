//
//  ShimmerBar.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import SwiftUI

struct ShimmerBar: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.placeholderGray)
                .overlay {
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.55),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.6)
                    .offset(x: phase * proxy.size.width)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .onAppear {
            phase = -1

            withAnimation(
                .linear(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1.6
            }
        }
    }
}
