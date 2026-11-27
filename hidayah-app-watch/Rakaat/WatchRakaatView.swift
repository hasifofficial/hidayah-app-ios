//
//  WatchRakaatView.swift
//  hidayah-app-watch
//

import SwiftUI

/// Shows the iPhone's live rakaat count. The phone on the mat does the
/// counting, so until it starts this asks you to begin there.
struct WatchRakaatView: View {
    let model: WatchRakaatModel

    private static let lineWidth: CGFloat = 12

    var body: some View {
        Group {
            if let prayer = model.completedPrayer {
                completion(prayer)
            } else if let prayer = model.displayedPrayer {
                counter(prayer)
            } else {
                waiting
            }
        }
        .navigationTitle(String(localized: "rakaat_header_title"))
    }

    // MARK: - Waiting

    private var waiting: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image("IllustrationRakaat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .accessibilityHidden(true)
                Text(String(localized: "watch_rakaat_waiting_title"))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(String(localized: "watch_rakaat_waiting_message"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
    }

    // MARK: - Counter

    private func counter(_ prayer: RakaatPrayer) -> some View {
        ZStack {
            Circle()
                .inset(by: Self.lineWidth / 2)
                .stroke(Color.lightGreen.opacity(0.22), lineWidth: Self.lineWidth)
            Circle()
                .inset(by: Self.lineWidth / 2)
                .trim(from: 0, to: model.progress)
                .stroke(
                    Color.lightGreen,
                    style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.2), value: model.progress)

            VStack(spacing: 0) {
                Text(
                    model.isTashahhudPrompt
                        ? String(localized: "rakaat_tashahhud_prompt")
                        : prayer.displayName
                )
                .font(.caption2)
                .foregroundStyle(Color.lightGreen)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: 76)
                Text("\(model.completedRakaat)")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(
                    String(
                        format: String(localized: "rakaat_count_of_format"),
                        model.rakaatCount
                    )
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                HStack(spacing: 5) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(
                                index < model.sujoodInCurrentRakaat
                                    ? Color.lightGreen
                                    : Color.secondary.opacity(0.4)
                            )
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Completion

    private func completion(_ prayer: RakaatPrayer) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.lightGreen)
                Text(String(localized: "rakaat_complete_title"))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(prayer.displayName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(String(localized: "rakaat_done")) {
                    model.dismissCompletion()
                }
                .tint(.lightGreen)
            }
            .padding(.top, 8)
        }
    }
}
