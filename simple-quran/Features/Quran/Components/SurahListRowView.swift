//
//  SurahListRowView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct SurahListRowView: View {
    let title: String
    let subtitle: String
    /// The Arabic name, read by VoiceOver and shown when there is no surah
    /// number to draw it with the surah-name font.
    let arabicTitle: String
    var surahNumber: Int? = nil
    var badgeText: String? = nil
    var badgeIcon: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if badgeText != nil || badgeIcon != nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Color.lightGreen.opacity(0.12))

                    if let badgeText {
                        Text(badgeText)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.lightGreen)
                    } else if let badgeIcon {
                        Image(systemName: badgeIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.lightGreen)
                    }
                }
                .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let ligature = surahNumber.flatMap(Font.surahNameLigature(for:)) {
                Text(ligature)
                    .font(.surahNameFont(size: 50))
                    .foregroundColor(.lightGreen)
                    .lineLimit(1)
                    .accessibilityLabel(arabicTitle)
            } else {
                Text(arabicTitle)
                    .font(.kitabBold(size: 20))
                    .foregroundColor(.lightGreen)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
