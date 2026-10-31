//
//  SurahRowView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import SwiftUI

struct SurahRowView: View {
    let title: String
    let subtitle: String
    let arabicTitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.textGray)
            }

            Spacer(minLength: 8)

            Text(arabicTitle)
                .font(.kitabBold(size: 22))
                .foregroundColor(.lightGreen)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
