//
//  ReaderTextBlock.swift
//  simple-quran
//

import SwiftUI

/// Arabic text in the reader's Arabic font, with an optional transliteration
/// and translation below it.
struct ReaderTextBlock: View {
    let arabic: String
    var latin: String?
    var translation: String?
    var translationIsRTL = false
    let arabicFontSize: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(arabic)
                .font(.kitabRegular(size: CGFloat(arabicFontSize)))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineSpacing(6)
                .padding(.horizontal, 16)
                .padding(.top, 10)

            if let latin {
                Text(latin)
                    .font(.system(size: 13).italic())
                    .foregroundColor(.textGray)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
            }

            if let translation {
                Text(translation)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .multilineTextAlignment(
                        translationIsRTL ? .trailing : .leading
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: translationIsRTL ? .trailing : .leading
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }
        }
    }
}

/// The hairline that ends each reader row.
struct ReaderRowDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.textGray.opacity(0.12))
            .padding(.horizontal, 16)
            .padding(.top, 18)
    }
}
