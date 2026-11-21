//
//  ReadingView.swift
//  hidayah-app
//

import SwiftUI

/// Landing page of the Reading tab: one card per reading collection,
/// each opening its own screen on the tab's navigation stack.
struct ReadingView: View {
    let onOpenQuran: () -> Void
    let onOpenMathurat: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                FeatureCard(
                    icon: "book.fill",
                    illustration: AppFeature.quran.illustration,
                    title: NSLocalizedString("surah_list_header_title", comment: ""),
                    subtitle: NSLocalizedString("reading_quran_subtitle", comment: ""),
                    action: onOpenQuran
                )
                .loadAnimation(offset: 12)

                FeatureCard(
                    icon: "sun.horizon.fill",
                    illustration: AppFeature.mathurat.illustration,
                    title: NSLocalizedString("mathurat_header_title", comment: ""),
                    subtitle: NSLocalizedString("reading_mathurat_subtitle", comment: ""),
                    action: onOpenMathurat
                )
                .loadAnimation(delay: 0.05, offset: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .background(.appBackground)
        .navigationTitle(NSLocalizedString("reading_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onOpenSettings) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
