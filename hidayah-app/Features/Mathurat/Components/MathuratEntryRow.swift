//
//  MathuratEntryRow.swift
//  simple-quran
//

import SwiftUI

/// One dhikr, du'a or Quran passage, laid out like an ayah in the Quran
/// reader.
struct MathuratEntryRow: View {
    let entry: MathuratEntry
    /// The entry's position in the current session, starting at 1.
    let number: Int
    let count: Int
    let arabicFontSize: Double
    let showTranslation: Bool
    let shareText: String
    let onCount: () -> Void

    private var name: String {
        entry.title ?? String(
            format: NSLocalizedString("mathurat_entry_fallback_title", comment: ""),
            number
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                NumberSealBadge(number: number)

                if let title = entry.title {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.title)
                }

                Spacer(minLength: 8)

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lightGreen)
                        .frame(width: 40, height: 40)
                        .background(Color.backgroundGray)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    String(
                        format: NSLocalizedString("mathurat_share_accessibility", comment: ""),
                        name
                    )
                )

                counter
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ReaderTextBlock(
                arabic: entry.arabic,
                translation: showTranslation ? entry.translation : nil,
                arabicFontSize: arabicFontSize,
                numberFont: Font.uthmanicDouri(size:)
            )

            ReaderRowDivider()
        }
        .padding(.top, 8)
    }

    private var counter: some View {
        ReaderCircleButton(
            isActive: false,
            accessibilityLabel: String(
                format: NSLocalizedString(
                    "mathurat_count_accessibility",
                    comment: ""
                ),
                name
            ),
            action: onCount
        ) {
            Text("\(count) / \(entry.repeatCount)")
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .frame(height: 40)
        }
        .accessibilityValue(
            String(
                format: NSLocalizedString("mathurat_repeat_format", comment: ""),
                count,
                entry.repeatCount
            )
        )
    }
}
