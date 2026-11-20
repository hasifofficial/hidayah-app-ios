//
//  MushafToolbar.swift
//  simple-quran
//

import SwiftUI

/// The floating bar above the page: back, where you are, the navigator and
/// reading settings. It stands in for the navigation bar so the page has
/// the screen to itself.
struct MushafToolbar: View {
    let pageLabel: String
    let detailLabel: String
    let onBack: () -> Void
    let onOpenNavigator: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            iconButton(
                systemName: "chevron.backward",
                label: NSLocalizedString("quran_mushaf_back", comment: ""),
                action: onBack
            )

            Button(action: onOpenNavigator) {
                VStack(spacing: 1) {
                    Text(pageLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.title)

                    Text(detailLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.textGray)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(NSLocalizedString("quran_mushaf_navigator_hint", comment: ""))

            iconButton(
                systemName: "rectangle.split.3x1",
                label: NSLocalizedString("quran_mushaf_navigator_title", comment: ""),
                action: onOpenNavigator
            )

            iconButton(
                systemName: "textformat.size",
                label: NSLocalizedString("quran_reading_settings_title", comment: ""),
                action: onOpenSettings
            )
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: 420)
        .modifier(MushafBarBackground())
        .padding(.horizontal, 16)
    }

    private func iconButton(
        systemName: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.lightGreen)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// Liquid Glass where the system has it, a material capsule before that.
struct MushafBarBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: Capsule())
        } else {
            content
                .background(.regularMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.textGray.opacity(0.12), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
    }
}
