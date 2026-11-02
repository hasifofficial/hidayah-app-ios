//
//  SettingsToggleRow.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.lightGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .settingsListRow()
    }
}
