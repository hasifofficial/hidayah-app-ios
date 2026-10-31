//
//  SettingsSectionHeader.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    var topPadding: CGFloat = 24

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.primary)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, topPadding)
            .padding(.bottom, 8)
            .settingsListRow()
    }
}
