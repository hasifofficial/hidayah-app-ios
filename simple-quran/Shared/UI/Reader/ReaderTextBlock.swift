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
    /// When set, ayah numbers in the Arabic (Arabic-Indic digits) use this
    /// font while the words stay in Kitab.
    var numberFont: ((CGFloat) -> Font)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            arabicText
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

extension ReaderTextBlock {
    @ViewBuilder
    private var arabicText: some View {
        let size = CGFloat(arabicFontSize)
        if let numberFont {
            Text(Self.styledArabic(arabic, size: size, numberFont: numberFont))
        } else {
            Text(arabic)
                .font(.kitabRegular(size: size))
        }
    }

    /// The Arabic in Kitab, with each run of Arabic-Indic digits in
    /// `numberFont`.
    nonisolated static func styledArabic(
        _ arabic: String,
        size: CGFloat,
        numberFont: (CGFloat) -> Font
    ) -> AttributedString {
        var result = AttributedString()
        var run = ""
        var runIsNumber = false

        func flush() {
            guard !run.isEmpty else { return }
            var part = AttributedString(run)
            part.font = runIsNumber ? numberFont(size) : .kitabRegular(size: size)
            result += part
            run = ""
        }

        for character in arabic {
            let isNumber = character.unicodeScalars.allSatisfy {
                (0x0660...0x0669).contains($0.value)
            }
            if isNumber != runIsNumber {
                flush()
                runIsNumber = isNumber
            }
            run.append(character)
        }
        flush()

        return result
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
