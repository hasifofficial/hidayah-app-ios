//
//  WhatsNewView.swift
//  simple-quran
//
//  An illustrated page for each new feature, shown once after an update
//  and again from Settings.
//

import SwiftUI

struct WhatsNewView: View {
    var release: WhatsNewRelease = .current

    @Environment(\.dismiss) private var dismiss
    @State private var index = 0

    private var isLastPage: Bool {
        index == release.features.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $index) {
                ForEach(Array(release.features.enumerated()), id: \.element.id) { offset, feature in
                    page(for: feature)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: index)

            pageDots
                .padding(.bottom, 20)

            AppPrimaryButton(
                title: NSLocalizedString(
                    isLastPage ? "whats_new_done" : "whats_new_next",
                    comment: ""
                ),
                icon: isLastPage ? "checkmark" : "arrow.right",
                isEnabled: true
            ) {
                if isLastPage {
                    dismiss()
                } else {
                    index += 1
                }
            }
            .frame(maxWidth: 420)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            release.markSeen()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(NSLocalizedString("whats_new_title", comment: ""))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.title)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(NSLocalizedString("whats_new_skip", comment: "")) {
                dismiss()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.textGray)
            .opacity(isLastPage ? 0 : 1)
            .disabled(isLastPage)
            .accessibilityHidden(isLastPage)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    private func page(for feature: WhatsNewFeature) -> some View {
        GeometryReader { proxy in
            ScrollView {
                pageContent(for: feature)
                    // Centred when it fits; scrolls at large text sizes.
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func pageContent(for feature: WhatsNewFeature) -> some View {
        Group {
            VStack(spacing: 20) {
                Image(feature.illustration)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 380)
                    .padding(.horizontal, 8)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text(NSLocalizedString(feature.titleKey, comment: ""))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.title)

                    Text(NSLocalizedString(feature.bodyKey, comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.textGray)
                        .lineSpacing(3)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 420)
                .accessibilityElement(children: .combine)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(release.features.indices, id: \.self) { offset in
                Capsule()
                    .fill(offset == index ? Color.lightGreen : Color.textGray.opacity(0.25))
                    .frame(width: offset == index ? 22 : 7, height: 7)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: index)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(
                format: NSLocalizedString("whats_new_page_format", comment: ""),
                index + 1,
                release.features.count
            )
        )
    }
}

#Preview {
    WhatsNewView()
}
