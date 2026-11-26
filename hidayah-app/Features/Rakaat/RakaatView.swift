//
//  RakaatView.swift
//  hidayah-app
//

import SwiftUI

/// Counts rakaat while you pray. Place the phone face up where your
/// forehead touches in sujood; each pair of sujood is one rakaat.
struct RakaatView: View {
    @Bindable var viewModel: RakaatViewModel

    @State private var customRakaat = 2
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            AppGradientBackground()

            switch viewModel.phase {
            case .setup:
                setup
            case .praying:
                praying
            case .finished:
                finished
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.phase)
        .navigationTitle(NSLocalizedString("rakaat_header_title", comment: ""))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if case .custom(let rakaat) = viewModel.prayer {
                customRakaat = rakaat
            }
        }
        .onDisappear {
            // Presenting the focus screen hides this one too; only leaving
            // the screen ends the prayer.
            guard !viewModel.showsFocusScreen else { return }
            viewModel.stop()
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.showsFocusScreen },
                set: { isPresented in
                    if !isPresented {
                        viewModel.stop()
                    }
                }
            )
        ) {
            RakaatFocusView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                viewModel.sceneDidBecomeActive()
            case .inactive, .background:
                viewModel.sceneWillResignActive()
            @unknown default:
                break
            }
        }
    }

    // MARK: - Setup

    private var setup: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                sectionTitle("rakaat_choose_prayer")

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(RakaatPrayer.presets) { prayer in
                        prayerChip(prayer)
                    }
                    prayerChip(.custom(rakaat: customRakaat))
                }

                if viewModel.prayer.isCustom {
                    Stepper(
                        value: $customRakaat,
                        in: RakaatPrayer.customRange
                    ) {
                        Text(rakaatCountText(customRakaat))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.title)
                    }
                    .onChange(of: customRakaat) { _, value in
                        viewModel.prayer = .custom(rakaat: value)
                    }
                    .padding(14)
                    .background(Color.backgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                instructions

                Toggle(isOn: $viewModel.usesFocusScreen) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(NSLocalizedString("rakaat_focus_toggle", comment: ""))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.title)
                        Text(NSLocalizedString("rakaat_focus_toggle_detail", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(.textGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(.lightGreen)
                .padding(14)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityIdentifier("rakaat_focus_toggle")

                Button {
                    AppHaptics.selection()
                    viewModel.start()
                } label: {
                    Text(NSLocalizedString("rakaat_start", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.lightGreen)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("rakaat_start")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            // Clear the floating tab bar.
            .padding(.bottom, 110)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
    }

    private func prayerChip(_ prayer: RakaatPrayer) -> some View {
        let isSelected = prayer.isCustom
            ? viewModel.prayer.isCustom
            : viewModel.prayer == prayer
        return Button {
            AppHaptics.selection()
            viewModel.prayer = prayer
        } label: {
            VStack(spacing: 2) {
                Text(prayer.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(rakaatCountText(prayer.rakaatCount))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.85) : .textGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.lightGreen : Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.textGray.opacity(isSelected ? 0 : 0.1), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("rakaat_how_title")
            HStack(alignment: .top, spacing: 12) {
                howToPicture(Illustration.rakaatPlacement, captionKey: "rakaat_how_picture_place")
                howToPicture(Illustration.rakaatSujood, captionKey: "rakaat_how_picture_sujood")
            }
            .padding(.bottom, 4)
            instructionRow(icon: "iphone", key: "rakaat_how_place")
            instructionRow(icon: "hand.raised", key: "rakaat_how_sujood")
            instructionRow(icon: "applewatch.radiowaves.left.and.right", key: "rakaat_how_watch")
        }
        .padding(16)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// A picture of how to set up, with a short caption under it.
    private func howToPicture(_ name: String, captionKey: String) -> some View {
        VStack(spacing: 6) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color.appBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)
            Text(NSLocalizedString(captionKey, comment: ""))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textGray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func instructionRow(icon: String, key: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.lightGreen)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(NSLocalizedString(key, comment: ""))
                .font(.system(size: 14))
                .foregroundColor(.title)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionTitle(_ key: String) -> some View {
        Text(NSLocalizedString(key, comment: ""))
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.textGray)
            .textCase(.uppercase)
    }

    // MARK: - Praying

    private static let ringWidth: CGFloat = 16

    private var praying: some View {
        VStack(spacing: 0) {
            Text(viewModel.prayer.displayName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.lightGreen)
                .padding(.top, 8)

            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .inset(by: Self.ringWidth / 2)
                    .stroke(Color.lightGreen.opacity(0.18), lineWidth: Self.ringWidth)
                Circle()
                    .inset(by: Self.ringWidth / 2)
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        Color.lightGreen,
                        style: StrokeStyle(lineWidth: Self.ringWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: viewModel.progress)

                VStack(spacing: 4) {
                    Text("\(viewModel.completedRakaat)")
                        .font(.system(size: 96, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.title)
                        .contentTransition(.numericText(value: Double(viewModel.completedRakaat)))
                        .animation(.spring(duration: 0.3), value: viewModel.completedRakaat)
                    Text(
                        String(
                            format: NSLocalizedString("rakaat_count_of_format", comment: ""),
                            viewModel.rakaatCount
                        )
                    )
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textGray)
                    sujoodDots
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: 280, maxHeight: 280)
            .padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                String(
                    format: NSLocalizedString("rakaat_accessibility_progress_format", comment: ""),
                    viewModel.completedRakaat,
                    viewModel.rakaatCount
                )
            )

            statusText
                .padding(.top, 24)
                .padding(.horizontal, 24)

            Spacer(minLength: 12)

            prayingControls
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sujoodDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(
                        index < viewModel.sujoodInCurrentRakaat
                            ? Color.lightGreen
                            : Color.textGray.opacity(0.25)
                    )
                    .frame(width: 10, height: 10)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.sujoodInCurrentRakaat)
    }

    private var statusText: some View {
        VStack(spacing: 6) {
            if viewModel.isTashahhudPrompt {
                Text(NSLocalizedString("rakaat_tashahhud_prompt", comment: ""))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.lightGreen)
            } else {
                Text(
                    String(
                        format: NSLocalizedString("rakaat_current_format", comment: ""),
                        viewModel.currentRakaat
                    )
                )
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.title)
            }

            Text(
                NSLocalizedString(
                    viewModel.isSensorAvailable ? "rakaat_listening" : "rakaat_sensor_unavailable",
                    comment: ""
                )
            )
            .font(.system(size: 13))
            .foregroundColor(.textGray)
            .multilineTextAlignment(.center)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isTashahhudPrompt)
    }

    private var prayingControls: some View {
        HStack(spacing: 12) {
            pillButton(title: "−1", accessibilityKey: "rakaat_decrement") {
                viewModel.decrement()
            }
            .disabled(viewModel.completedRakaat == 0 && viewModel.sujoodInCurrentRakaat == 0)

            Spacer()

            pillButton(title: NSLocalizedString("rakaat_end", comment: ""), accessibilityKey: nil) {
                viewModel.stop()
            }

            pillButton(title: "+1", accessibilityKey: "rakaat_increment") {
                viewModel.increment()
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 560)
    }

    private func pillButton(
        title: String,
        accessibilityKey: String?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.title)
                .padding(.horizontal, 20)
                .frame(minWidth: 58)
                .frame(height: 46)
                .background(Color.backgroundGray)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(Color.textGray.opacity(0.12), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            accessibilityKey.map { NSLocalizedString($0, comment: "") } ?? title
        )
    }

    // MARK: - Finished

    private var finished: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(.lightGreen)
                .accessibilityHidden(true)
            Text(NSLocalizedString("rakaat_complete_title", comment: ""))
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.title)
            Text(
                String(
                    format: NSLocalizedString("rakaat_complete_message_format", comment: ""),
                    viewModel.rakaatCount,
                    viewModel.prayer.displayName
                )
            )
            .font(.system(size: 15))
            .foregroundColor(.textGray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            Spacer()
            HStack(spacing: 12) {
                pillButton(title: NSLocalizedString("rakaat_done", comment: ""), accessibilityKey: nil) {
                    viewModel.done()
                }
                pillButton(title: NSLocalizedString("rakaat_pray_again", comment: ""), accessibilityKey: nil) {
                    viewModel.start()
                }
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
    }

    private func rakaatCountText(_ count: Int) -> String {
        String(format: NSLocalizedString("rakaat_count_format", comment: ""), count)
    }
}
