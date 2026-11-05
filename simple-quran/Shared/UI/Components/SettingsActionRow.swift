//
//  SettingsActionRow.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct SettingsActionRow: View {
    let icon: String
    let title: String
    var value: String?
    var showsDisclosure: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 32, height: 32)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)

                Spacer(minLength: 8)

                if let value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.textGray)
                        .lineLimit(1)
                }

                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textGray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingsListRow()
    }
}
