//
//  ExploreView.swift
//  hidayah-app
//

import SwiftUI

/// The app's main features in one list, opened from Home.
struct ExploreView: View {
    let onOpen: (AppFeature) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(AppFeature.allCases.enumerated()), id: \.element.id) { index, feature in
                    FeatureCard(
                        icon: feature.icon,
                        assetIcon: feature.assetIcon,
                        illustration: feature.illustration,
                        title: feature.title,
                        subtitle: feature.subtitle
                    ) {
                        onOpen(feature)
                    }
                    .loadAnimation(delay: Double(index) * 0.04, offset: 12)
                }
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .background(.appBackground)
        .navigationTitle(NSLocalizedString("explore_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
    }
}
