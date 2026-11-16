//
//  ReadingView.swift
//  simple-quran
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
                    title: NSLocalizedString("surah_list_header_title", comment: ""),
                    subtitle: NSLocalizedString("reading_quran_subtitle", comment: ""),
                    action: onOpenQuran
                )
                .loadAnimation(offset: 12)

                FeatureCard(
                    icon: "sun.horizon.fill",
                    title: NSLocalizedString("mathurat_header_title", comment: ""),
                    subtitle: NSLocalizedString("reading_mathurat_subtitle", comment: ""),
                    action: onOpenMathurat
                )
                .loadAnimation(delay: 0.05, offset: 12)
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
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
