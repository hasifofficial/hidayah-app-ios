//
//  QuranReadingSettingsView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct QuranReadingSettingsView: View {
    @AppStorage(
        Storage.StorageKey.quranArabicFontSize.rawValue,
        store: Storage.userDefaults
    ) private var arabicFontSize = 22.0

    @AppStorage(
        Storage.StorageKey.quranShowTranslation.rawValue,
        store: Storage.userDefaults
    ) private var showTranslation = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    previewCard
                    settingsCard
                }
                .padding(16)
            }
            .background(.appBackground)
            .navigationTitle(
                NSLocalizedString(
                    "quran_reading_settings_title",
                    comment: ""
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        NSLocalizedString(
                            "quran_reading_reset",
                            comment: ""
                        )
                    ) {
                        arabicFontSize = 22
                        showTranslation = true
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        NSLocalizedString(
                            "quran_reading_done",
                            comment: ""
                        )
                    ) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.lightGreen)
                }
            }
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(
                NSLocalizedString(
                    "quran_reading_preview_title",
                    comment: ""
                )
            )
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.textGray)
            .textCase(.uppercase)

            VStack(spacing: 0) {
                previewAyah(
                    number: 1,
                    arabic: "وَٱلْعَصْرِ",
                    translation: "By time,"
                )

                previewAyah(
                    number: 2,
                    arabic: "إِنَّ ٱلْإِنسَٰنَ لَفِى خُسْرٍ",
                    translation: "Indeed, mankind is in loss."
                )
            }
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
            }
        }
    }

    private func previewAyah(
        number: Int,
        arabic: String,
        translation: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.lightGreen)

                    Text("\(number)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer(minLength: 8)

                previewAction(icon: "square.and.arrow.up")
                previewAction(icon: "play.fill")
                previewAction(icon: "bookmark")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text(arabic)
                .font(.kitabRegular(size: CGFloat(arabicFontSize)))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineSpacing(6)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .animation(.easeInOut(duration: 0.15), value: arabicFontSize)

            if showTranslation {
                Text(translation)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }

            Divider()
                .overlay(Color.textGray.opacity(0.12))
                .padding(.horizontal, 16)
                .padding(.top, 14)
        }
        .padding(.top, 6)
    }

    private func previewAction(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.lightGreen)
            .frame(width: 30, height: 30)
            .background(Color.appBackground.opacity(0.7))
            .clipShape(Circle())
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(
                        NSLocalizedString(
                            "quran_reading_arabic_size",
                            comment: ""
                        )
                    )
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.title)

                    Spacer()

                    Text(
                        String(
                            format: NSLocalizedString("quran_font_size_value_format", comment: ""),
                            Int(arabicFontSize)
                        )
                    )
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }

                HStack(spacing: 8) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 13))
                        .foregroundColor(.textGray)

                    Slider(
                        value: $arabicFontSize,
                        in: 16...34,
                        step: 1
                    )
                    .tint(.lightGreen)

                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 15))
                        .foregroundColor(.textGray)
                }
            }
            .padding(16)

            Divider()
                .overlay(Color.textGray.opacity(0.08))
                .padding(.horizontal, 16)

            HStack(spacing: 8) {
                Image(systemName: "character.book.closed")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                    .frame(width: 28)

                Text(
                    NSLocalizedString(
                        "quran_reading_show_translation",
                        comment: ""
                    )
                )
                .font(.system(size: 14))
                .foregroundColor(.title)

                Spacer()

                Toggle("", isOn: $showTranslation)
                    .labelsHidden()
                    .tint(.lightGreen)
            }
            .padding(16)
        }
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.textGray.opacity(0.06), lineWidth: 1)
        }
    }
}
