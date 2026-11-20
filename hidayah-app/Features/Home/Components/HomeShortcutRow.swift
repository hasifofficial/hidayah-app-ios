//
//  HomeShortcutRow.swift
//  hidayah-app
//

import SwiftUI

/// The row of feature shortcuts on Home, ending with the "All" tile. Also
/// drawn as a preview in Settings › Home Shortcuts.
struct HomeShortcutRow: View {
    let features: [AppFeature]
    let onOpen: (AppFeature) -> Void
    let onOpenAll: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(features) { feature in
                HomeShortcutTile(
                    icon: feature.icon,
                    assetIcon: feature.assetIcon,
                    illustration: feature.illustration,
                    title: feature.shortTitle,
                    accessibilityLabel: feature.title
                ) {
                    onOpen(feature)
                }
            }

            HomeShortcutTile(
                icon: "square.grid.2x2.fill",
                illustration: AppFeature.allIllustration,
                title: NSLocalizedString("home_explore_all", comment: ""),
                accessibilityLabel: NSLocalizedString("home_explore_all_accessibility", comment: ""),
                action: onOpenAll
            )
        }
    }
}

struct HomeShortcutTile: View {
    let icon: String
    var assetIcon: String? = nil
    var illustration: String? = nil
    let title: String
    var accessibilityLabel: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.backgroundGray)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.lightGreen.opacity(0.12), lineWidth: 1)
                        }

                    if let illustration {
                        Image(illustration)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .accessibilityHidden(true)
                    } else {
                        FeatureIcon(systemName: icon, assetName: assetIcon, size: 20)
                    }
                }
                .frame(height: 58)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityAddTraits(.isButton)
    }
}
