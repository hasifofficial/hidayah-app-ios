//
//  QuickAccessSurahCard.swift
//  simple-quran
//

import SwiftUI

/// A compact surah card, shown in the Quick Access rows of the Quran list
/// and Home, and for bookmarks on Home (with the verse as `detail`).
struct QuickAccessSurahCard: View {
    /// Surahs offered for quick access, in display order.
    static let surahNumbers = [18, 32, 36, 56, 67]

    let surah: SurahListResponse
    /// An extra line under the name, such as the bookmarked verse.
    var detail: String? = nil
    var icon = "book.fill"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.lightGreen.opacity(0.14))

                    Text("\(surah.number ?? 0)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 28, height: 28)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.lightGreen.opacity(0.75))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.englishName ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)

                if let detail {
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textGray)
                        .lineLimit(1)
                }
            }

            if let ligature = surah.number.flatMap(Font.surahNameLigature(for:)) {
                Text(ligature)
                    .font(.surahNameFont(size: 44))
                    .foregroundColor(.lightGreen)
                    .lineLimit(1)
            } else {
                Text(surah.name ?? "")
                    .font(.kitabBold(size: 20))
                    .foregroundColor(.lightGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(width: 142, alignment: .leading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.14),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.14), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [surah.englishName, detail, surah.name]
                .compactMap { $0 }
                .joined(separator: ", ")
        )
    }
}

extension Array where Element == SurahListResponse {
    /// The quick access surahs found in this list, in display order.
    var quickAccessSurahs: [SurahListResponse] {
        QuickAccessSurahCard.surahNumbers.compactMap { number in
            first { $0.number == number }
        }
    }
}
