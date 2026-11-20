//
//  WatchTasbihView.swift
//  hidayah-app-watch
//

import SwiftUI

/// Tasbih on the wrist: tap anywhere or turn the Digital Crown to count.
/// Counting lives in the shared `TasbihViewModel`.
struct WatchTasbihView: View {
    @State private var viewModel = TasbihViewModel()
    @State private var crownValue = 0.0
    @State private var crownBaseline = 0.0

    /// Crown travel that counts as one bead.
    private let crownStep = 1.0
    /// The crown runs round a small range that wraps, like a dial. Its
    /// scroll indicator is drawn from the range, and an infinite or huge
    /// range makes the indicator's position NaN, which crashes.
    private static let crownRange = 100.0

    var body: some View {
        Group {
            if viewModel.showCompletion {
                completion
            } else {
                counter
            }
        }
        .navigationTitle(String(localized: "tasbih_header_title"))
        .toolbar {
            // The completion screen has its own Start Again button, which
            // these would cover.
            if !viewModel.showCompletion {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        viewModel.resetCurrent()
                        crownBaseline = crownValue
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel(String(localized: "tasbih_reset"))

                    Spacer()

                    Button {
                        viewModel.toggleFreeCount()
                    } label: {
                        // The button is filled with the tint, so the icon is white.
                        Image(systemName: viewModel.isFreeCount ? "infinity.circle.fill" : "infinity")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel(String(localized: "tasbih_free_count"))
                }
            }
        }
    }

    /// Matches the Istiqamah progress ring on the Watch.
    private static let lineWidth: CGFloat = 14

    private var counter: some View {
        VStack {
            ZStack {
                // A stroke is centred on the shape's edge, so inset the
                // circle by half the line width to keep the whole ring
                // inside its frame.
                Circle()
                    .inset(by: Self.lineWidth / 2)
                    .stroke(Color.lightGreen.opacity(0.22), lineWidth: Self.lineWidth)
                if !viewModel.isFreeCount {
                    Circle()
                        .inset(by: Self.lineWidth / 2)
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            Color.lightGreen,
                            style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.15), value: viewModel.progress)
                }
                VStack(spacing: 0) {
                    Text(
                        viewModel.isFreeCount
                            ? String(localized: "tasbih_free_count")
                            : String(localized: String.LocalizationValue(viewModel.currentPhrase.nameKey))
                    )
                    .font(.caption2)
                    .foregroundStyle(Color.lightGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    // Above the count the circle is narrower, so keep the
                    // name to a width that clears the ring.
                    .frame(maxWidth: 76)
                    Text("\(viewModel.displayedCount)")
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    if !viewModel.isFreeCount {
                        Text(
                            String(
                                format: String(localized: "tasbih_count_of_format"),
                                viewModel.target
                            )
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
            .scaleEffect(viewModel.isCompleting ? 1.04 : 1)
            .animation(.spring(duration: 0.3), value: viewModel.isCompleting)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.increment()
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Self.crownRange,
            by: crownStep,
            sensitivity: .low,
            isContinuous: true,
            isHapticFeedbackEnabled: false
        )
        .onChange(of: crownValue) { _, newValue in
            handleCrown(newValue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(String(localized: "watch_tasbih_hint"))
        .accessibilityAction {
            viewModel.increment()
        }
    }

    private var completion: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.lightGreen)
                Text(String(localized: "tasbih_completion_title"))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Button(String(localized: "tasbih_start_again")) {
                    viewModel.startAgain()
                    crownBaseline = crownValue
                }
                .tint(.lightGreen)
            }
            .padding(.top, 8)
        }
    }

    /// Turns whole crown steps into beads: forward counts, back undoes.
    private func handleCrown(_ value: Double) {
        let steps = Self.crownSteps(from: crownBaseline, to: value, step: crownStep)
        guard steps != 0 else { return }
        crownBaseline = value

        if steps > 0 {
            for _ in 0..<steps {
                viewModel.increment()
            }
        } else {
            for _ in 0..<(-steps) {
                viewModel.decrement()
            }
        }
    }

    /// Whole steps turned from `old` to `new`. Crossing the wrap point
    /// takes the short way round, so 99 → 1 is two steps forward.
    static func crownSteps(from old: Double, to new: Double, step: Double) -> Int {
        var delta = new - old
        if delta > crownRange / 2 {
            delta -= crownRange
        } else if delta < -crownRange / 2 {
            delta += crownRange
        }
        return Int((delta / step).rounded(.towardZero))
    }
}
