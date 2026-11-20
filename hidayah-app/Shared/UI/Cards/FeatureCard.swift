//
//  FeatureCard.swift
//  hidayah-app
//

import SwiftUI

/// A tappable row with an icon, title and one-line description, used to
/// open a feature from Reading and Explore.
struct FeatureCard: View {
    let icon: String
    var assetIcon: String? = nil
    var illustration: String? = nil
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let illustration {
                    Image(illustration)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .accessibilityHidden(true)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.lightGreen.opacity(0.12))

                        FeatureIcon(systemName: icon, assetName: assetIcon, size: 19)
                    }
                    .frame(width: 46, height: 46)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.title)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.textGray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textGray)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
