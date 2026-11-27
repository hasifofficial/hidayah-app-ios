//
//  RakaatGuideView.swift
//  hidayah-app
//
//  How to place the phone, one illustrated page per step, and the Apple
//  Watch tip. Laid out like the What's New screen so the two feel the same.
//

import SwiftUI

struct RakaatGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0

    private struct Step: Identifiable {
        /// Name of the illustration in the asset catalog.
        let illustration: String
        let titleKey: String
        let bodyKey: String

        var id: String { illustration }
    }

    private let steps = [
        Step(
            illustration: Illustration.rakaatPlacement,
            titleKey: "rakaat_how_picture_place",
            bodyKey: "rakaat_guide_place_detail"
        ),
        Step(
            illustration: Illustration.rakaatSujood,
            titleKey: "rakaat_how_picture_sujood",
            bodyKey: "rakaat_guide_sujood_detail"
        ),
        // The phone lies on the mat, so the Watch is where the cues are felt.
        Step(
            illustration: Illustration.rakaatWatch,
            titleKey: "rakaat_guide_watch_title",
            bodyKey: "rakaat_guide_watch_detail"
        )
    ]

    private var isLastPage: Bool {
        index == steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $index) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { offset, step in
                    page(for: step)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: index)

            pageDots
                .padding(.bottom, 20)

            AppPrimaryButton(
                title: NSLocalizedString(
                    isLastPage ? "rakaat_done" : "rakaat_guide_next",
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
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(NSLocalizedString("rakaat_guide_title", comment: ""))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.title)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(NSLocalizedString("rakaat_guide_skip", comment: "")) {
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

    private func page(for step: Step) -> some View {
        GeometryReader { proxy in
            ScrollView {
                pageContent(for: step)
                    // Centred when it fits; scrolls at large text sizes.
                    .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func pageContent(for step: Step) -> some View {
        VStack(spacing: 20) {
            Image(step.illustration)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 380)
                .padding(.horizontal, 8)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text(NSLocalizedString(step.titleKey, comment: ""))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.title)

                Text(NSLocalizedString(step.bodyKey, comment: ""))
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

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(steps.indices, id: \.self) { offset in
                Capsule()
                    .fill(offset == index ? Color.lightGreen : Color.textGray.opacity(0.25))
                    .frame(width: offset == index ? 22 : 7, height: 7)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: index)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(
                format: NSLocalizedString("rakaat_guide_page_format", comment: ""),
                index + 1,
                steps.count
            )
        )
    }
}
