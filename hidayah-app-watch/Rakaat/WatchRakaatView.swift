//
//  WatchRakaatView.swift
//  hidayah-app-watch
//

import SwiftUI

/// Shows the iPhone's live count, or counts on the Watch with a tap or the
/// Digital Crown after each rakaat.
struct WatchRakaatView: View {
    @Bindable var model: WatchRakaatModel

    @State private var crownValue = 0.0
    @State private var crownBaseline = 0.0

    private static let lineWidth: CGFloat = 12

    var body: some View {
        Group {
            if let prayer = model.completedPrayer {
                completion(prayer)
            } else if model.isMirroring || model.counter != nil {
                counter
            } else {
                picker
            }
        }
        .navigationTitle(String(localized: "rakaat_header_title"))
    }

    // MARK: - Picker

    private var picker: some View {
        List {
            ForEach(RakaatPrayer.presets) { prayer in
                Button {
                    model.prayer = prayer
                    model.start()
                    crownBaseline = crownValue
                } label: {
                    HStack {
                        Text(prayer.displayName)
                        Spacer()
                        Text(
                            String(
                                format: String(localized: "rakaat_count_format"),
                                prayer.rakaatCount
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Counter

    private var counter: some View {
        VStack(spacing: 4) {
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
                            : model.displayedPrayer.displayName
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
                    if model.isMirroring {
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
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)

            Text(
                model.isMirroring
                    ? String(localized: "watch_rakaat_live")
                    : String(localized: "watch_rakaat_hint")
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            model.increment()
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: 100,
            by: 1,
            sensitivity: .low,
            isContinuous: true,
            isHapticFeedbackEnabled: false
        )
        .onChange(of: crownValue) { _, newValue in
            handleCrown(newValue)
        }
        .toolbar {
            if !model.isMirroring {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        model.stop()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(String(localized: "watch_rakaat_hint"))
        .accessibilityAction {
            model.increment()
        }
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

    /// Whole Crown steps: forward adds a rakaat, back takes one away.
    private func handleCrown(_ value: Double) {
        let steps = WatchTasbihView.crownSteps(from: crownBaseline, to: value, step: 1)
        guard steps != 0 else { return }
        crownBaseline = value
        if steps > 0 {
            model.increment()
        } else {
            model.decrement()
        }
    }
}
