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
    @State private var showingGuide = false
    @State private var showingTashahhudInfo = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // The setup screen is plain like Explore; counting keeps the
            // soft green gradient.
            if viewModel.phase == .setup {
                Color.appBackground.ignoresSafeArea()
            } else {
                AppGradientBackground()
            }

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
            VStack(spacing: 16) {
                heroCard
                prayerPills
                VStack(spacing: 10) {
                    guideRow
                    darkScreenRow
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .frame(maxWidth: 560)
        }
        .sheet(isPresented: $showingGuide) {
            RakaatGuideView()
        }
    }

    /// The chosen prayer: its name, how many rakaat it has, and a dot for
    /// each rakaat with the tashahhud ones filled. For Custom, − and +
    /// change the count here.
    private var heroCard: some View {
        ReaderHeaderCard(
            icon: "figure.mind.and.body",
            illustration: AppFeature.rakaat.illustration,
            label: NSLocalizedString("rakaat_hero_label", comment: ""),
            title: viewModel.prayer.displayName,
            insetsFromEdges: false
        ) {
            HStack(alignment: .center, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(viewModel.prayer.rakaatCount)")
                        .font(.system(size: 64, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.title)
                        .contentTransition(.numericText(value: Double(viewModel.prayer.rakaatCount)))
                    Text(NSLocalizedString("rakaat_unit", comment: ""))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.textGray)
                }

                Spacer(minLength: 0)

                if viewModel.prayer.isCustom {
                    stepButton(systemName: "minus", accessibilityKey: "rakaat_custom_fewer") {
                        setCustomRakaat(customRakaat - 1)
                    }
                    .disabled(customRakaat <= RakaatPrayer.customRange.lowerBound)
                    stepButton(systemName: "plus", accessibilityKey: "rakaat_custom_more") {
                        setCustomRakaat(customRakaat + 1)
                    }
                    .disabled(customRakaat >= RakaatPrayer.customRange.upperBound)
                }
            }

            rakaatDots

            Button {
                showingTashahhudInfo = true
            } label: {
                HStack(spacing: 6) {
                    Label(tashahhudText, systemImage: "circle.fill")
                        .labelStyle(TashahhudLegendStyle())
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textGray)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(NSLocalizedString("rakaat_tashahhud_info_hint", comment: ""))
            .popover(isPresented: $showingTashahhudInfo) {
                tashahhudInfo
                    .presentationCompactAdaptation(.popover)
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.prayer)
    }

    /// One dot per rakaat, numbered; the rakaat you sit for tashahhud after
    /// are filled.
    private var rakaatDots: some View {
        let count = viewModel.prayer.rakaatCount
        let size: CGFloat = count > 8 ? 22 : 28
        return HStack(spacing: count > 8 ? 4 : 8) {
            ForEach(1...count, id: \.self) { rakaat in
                let isTashahhud = viewModel.prayer.tashahhudRakaat.contains(rakaat)
                Text("\(rakaat)")
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundColor(isTashahhud ? .white : .lightGreen)
                    .frame(width: size, height: size)
                    .background(
                        Circle().fill(isTashahhud ? Color.lightGreen : Color.appBackground.opacity(0.8))
                    )
                    .overlay {
                        Circle().stroke(Color.lightGreen.opacity(isTashahhud ? 0 : 0.4), lineWidth: 1.5)
                    }
            }
        }
        .accessibilityHidden(true)
    }

    /// What tashahhud is, for anyone who doesn't know the word.
    private var tashahhudInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("rakaat_tashahhud_info_title", comment: ""))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.title)
            Text(NSLocalizedString("rakaat_tashahhud_info_body", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(.textGray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(width: 290, alignment: .leading)
    }

    private var tashahhudText: String {
        let positions = viewModel.prayer.tashahhudRakaat
        if positions.count == 2 {
            return String(
                format: NSLocalizedString("rakaat_tashahhud_two_format", comment: ""),
                positions[0], positions[1]
            )
        }
        return String(
            format: NSLocalizedString("rakaat_tashahhud_one_format", comment: ""),
            positions.last ?? viewModel.prayer.rakaatCount
        )
    }

    private func stepButton(
        systemName: String,
        accessibilityKey: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            AppHaptics.selection()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.lightGreen)
                .frame(width: 40, height: 40)
                .background(Color.appBackground.opacity(0.8), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString(accessibilityKey, comment: ""))
    }

    private func setCustomRakaat(_ value: Int) {
        let clamped = min(max(value, RakaatPrayer.customRange.lowerBound), RakaatPrayer.customRange.upperBound)
        customRakaat = clamped
        viewModel.prayer = .custom(rakaat: clamped)
    }

    /// Every choice visible at once: two rows of three.
    private var prayerPills: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(RakaatPrayer.presets) { prayer in
                prayerPill(prayer)
            }
            prayerPill(.custom(rakaat: customRakaat))
        }
    }

    private func prayerPill(_ prayer: RakaatPrayer) -> some View {
        let isSelected = prayer.isCustom
            ? viewModel.prayer.isCustom
            : viewModel.prayer == prayer
        return Button {
            AppHaptics.selection()
            viewModel.prayer = prayer
        } label: {
            Text(prayer.displayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color.lightGreen : Color.backgroundGray, in: Capsule())
                .overlay {
                    Capsule().stroke(Color.textGray.opacity(isSelected ? 0 : 0.1), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(prayer.displayName), \(rakaatCountText(prayer.rakaatCount))")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var guideRow: some View {
        Button {
            showingGuide = true
        } label: {
            HStack(spacing: 12) {
                rowIcon("iphone")
                Text(NSLocalizedString("rakaat_how_open", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textGray)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var darkScreenRow: some View {
        Toggle(isOn: $viewModel.usesFocusScreen) {
            HStack(spacing: 12) {
                rowIcon("moon.fill")
                Text(NSLocalizedString("rakaat_focus_toggle", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.title)
            }
        }
        .tint(.lightGreen)
        .padding(12)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityHint(NSLocalizedString("rakaat_focus_toggle_detail", comment: ""))
        .accessibilityIdentifier("rakaat_focus_toggle")
    }

    private func rowIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.lightGreen)
            .frame(width: 32, height: 32)
            .background(Color.lightGreen.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .accessibilityHidden(true)
    }

    private var startButton: some View {
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

/// The legend under the rakaat dots: a small filled green dot, then the text.
private struct TashahhudLegendStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon
                .font(.system(size: 8))
                .foregroundColor(.lightGreen)
            configuration.title
        }
    }
}
