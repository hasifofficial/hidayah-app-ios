//
//  ReaderCircleButton.swift
//  simple-quran
//

import SwiftUI

/// The round 40pt action button on a reader row: green on grey, or white on
/// green while active.
struct ReaderCircleButton<Label: View>: View {
    let isActive: Bool
    let accessibilityLabel: String
    let action: () -> Void
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) {
            label
                .foregroundColor(isActive ? .white : .lightGreen)
                .frame(minWidth: 40, minHeight: 40)
                .background(isActive ? Color.lightGreen : Color.backgroundGray)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

extension ReaderCircleButton where Label == ReaderCircleIcon {
    init(
        icon: String,
        isActive: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.init(
            isActive: isActive,
            accessibilityLabel: accessibilityLabel,
            action: action
        ) {
            ReaderCircleIcon(systemName: icon)
        }
    }
}

struct ReaderCircleIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 40, height: 40)
    }
}
