//
//  RakaatFocusView.swift
//  hidayah-app
//

import SwiftUI

/// The screen while you pray: pure black, which leaves OLED pixels off, with
/// only the count and the tashahhud cue in dim text. Tap to show the
/// controls for a few seconds.
struct RakaatFocusView: View {
    @Bindable var viewModel: RakaatViewModel

    @State private var showsControls = false
    @State private var hideControlsTask: Task<Void, Never>?

    /// How long the controls stay after a tap.
    private static let controlsDuration: TimeInterval = 8
    /// How far the text drifts, so the same pixels aren't lit for the whole
    /// prayer.
    private static let driftRadius: CGFloat = 12

    var body: some View {
        ZStack {
            // The black fills the screen and takes the taps, so a tap
            // anywhere shows the controls.
            Color.black
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    revealControls()
                }

            TimelineView(.periodic(from: .now, by: 60)) { context in
                content
                    .contentShape(Rectangle())
                    .onTapGesture {
                        revealControls()
                    }
                    .offset(drift(at: context.date))
                    .animation(.easeInOut(duration: 2), value: drift(at: context.date))
            }

            if showsControls {
                VStack {
                    Spacer()
                    controls
                        .padding(.bottom, 32)
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .preferredColorScheme(.dark)
        .onDisappear {
            hideControlsTask?.cancel()
        }
    }

    private var content: some View {
        VStack(spacing: 12) {
            Text("\(viewModel.completedRakaat)")
                .font(.system(size: 180, weight: .ultraLight, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white.opacity(0.55))
                .contentTransition(.numericText(value: Double(viewModel.completedRakaat)))
                .animation(.easeOut(duration: 0.4), value: viewModel.completedRakaat)

            Text(
                String(
                    format: NSLocalizedString("rakaat_count_of_format", comment: ""),
                    viewModel.rakaatCount
                )
            )
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.white.opacity(0.3))

            Text(NSLocalizedString("rakaat_tashahhud_prompt", comment: ""))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color.lightGreen.opacity(0.7))
                .padding(.top, 16)
                .opacity(viewModel.isTashahhudPrompt ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTashahhudPrompt)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityHint(NSLocalizedString("rakaat_focus_hint", comment: ""))
        .accessibilityAction {
            revealControls()
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            focusButton(title: "−1", accessibilityKey: "rakaat_decrement") {
                viewModel.decrement()
            }
            focusButton(title: NSLocalizedString("rakaat_end", comment: ""), accessibilityKey: nil) {
                viewModel.stop()
            }
            focusButton(title: "+1", accessibilityKey: "rakaat_increment") {
                viewModel.increment()
            }
        }
    }

    private func focusButton(
        title: String,
        accessibilityKey: String?,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            revealControls()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 20)
                .frame(minWidth: 64)
                .frame(height: 46)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.map { NSLocalizedString($0, comment: "") } ?? title)
    }

    private var accessibilityText: String {
        var text = String(
            format: NSLocalizedString("rakaat_accessibility_progress_format", comment: ""),
            viewModel.completedRakaat,
            viewModel.rakaatCount
        )
        if viewModel.isTashahhudPrompt {
            text += ". " + NSLocalizedString("rakaat_tashahhud_prompt", comment: "")
        }
        return text
    }

    private func revealControls() {
        withAnimation(.easeOut(duration: 0.2)) {
            showsControls = true
        }
        hideControlsTask?.cancel()
        hideControlsTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(Self.controlsDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.4)) {
                showsControls = false
            }
        }
    }

    /// A slow drift that moves once a minute, going round a small circle.
    private func drift(at date: Date) -> CGSize {
        let minute = Int(date.timeIntervalSinceReferenceDate / 60)
        let angle = Double(minute % 8) * .pi / 4
        return CGSize(
            width: cos(angle) * Self.driftRadius,
            height: sin(angle) * Self.driftRadius
        )
    }
}
