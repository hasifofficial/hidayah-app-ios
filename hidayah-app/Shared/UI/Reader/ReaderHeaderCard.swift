//
//  ReaderHeaderCard.swift
//  simple-quran
//

import SwiftUI

/// The green-tinted card at the top of a reading screen: an icon tile, a
/// small uppercase label and a bold title, followed by `content`.
struct ReaderHeaderCard<Content: View>: View {
    let icon: String
    let label: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.lightGreen.opacity(0.12))

                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.textGray)
                        .textCase(.uppercase)

                    Text(title)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(.title)
                }

                Spacer(minLength: 0)
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.14),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}
