//
//  ListRowPlaceholder.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct ListRowPlaceholder: View {
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 16) {
                    ShimmerBar()
                        .frame(width: proxy.size.width * 0.30, height: 12)

                    ShimmerBar()
                        .frame(width: proxy.size.width * 0.45, height: 12)
                }

                Spacer(minLength: 8)

                ShimmerBar()
                    .frame(width: proxy.size.width * 0.30, height: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(height: 76)
    }
}
