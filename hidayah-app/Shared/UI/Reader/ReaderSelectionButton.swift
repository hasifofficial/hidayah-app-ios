//
//  ReaderSelectionButton.swift
//  simple-quran
//

import SwiftUI

/// A full-width button in a reader header, such as the reciter or
/// translation picker.
struct ReaderSelectionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lightGreen)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
