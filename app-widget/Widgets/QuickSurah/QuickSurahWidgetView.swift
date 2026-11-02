//
//  QuickSurahWidgetView.swift
//  app-widget
//

import SwiftUI
import WidgetKit

// MARK: - View

struct QuickSurahWidgetEntryView: View {
    var entry: QuickSurahEntry

    init(entry: QuickSurahEntry) {
        self.entry = entry
        WidgetFontLoader.registerFonts()
    }

    var body: some View {
        VStack(spacing: 6) {
            header

            HStack(spacing: 8) {
                ForEach(Array(entry.surahs.prefix(3))) { surah in
                    Link(
                        destination: URL(
                            string: "hidayahapp://inAppDeeplink/quran/\(surah.number)"
                        )!
                    ) {
                        surahCard(surah)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .widgetURL(
            URL(string: "hidayahapp://inAppDeeplink/quran")
        )
        .containerBackground(for: .widget) {
            QuickSurahWidgetBackground()
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image("hidayah_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 29)

            Text(
                NSLocalizedString(
                    "widget_quick_access_title",
                    comment: ""
                )
            )
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.title)

            Spacer(minLength: 4)

            Image(systemName: "book.closed.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.lightGreen)
        }
        .frame(height: 29)
    }

    private func surahCard(_ surah: QuickSurahEntity) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.lightGreen.opacity(0.16))

                    Text("\(surah.number)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 20, height: 20)

                Spacer(minLength: 2)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.textGray.opacity(0.65))
            }

            Spacer(minLength: 2)

            Text(surah.arabicName)
                .font(.custom("Kitab-Regular", size: 22))
                .foregroundColor(.title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(surah.englishName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textGray)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.top, 3)
        }
        .padding(8)
        .frame(width: 96, height: 96)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.lightGreen.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.14), lineWidth: 1)
        }
    }
}

struct QuickSurahWidgetBackground: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)

            LinearGradient(
                colors: [
                    Color.lightGreen.opacity(0.18),
                    Color.lightGreen.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
