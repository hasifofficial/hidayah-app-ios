//
//  TasbihView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/02/26.
//

import SwiftUI

struct TasbihView: View {
    let onOpenSettings: () -> Void

    @Bindable private var viewModel = TasbihViewModel()
    @State private var pulse = false
    @State private var isPresented = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                entrance(delay: 0.04) {
                    countingContent
                }

                entrance(delay: 0.14) {
                    controls
                        .padding(.top, 16)
                        .padding(.bottom, 96)
                }
            }
        }
        .alert(
            NSLocalizedString("tasbih_completion_title", comment: ""),
            isPresented: $viewModel.showCompletion
        ) {
            Button(
                NSLocalizedString("tasbih_start_again", comment: "")
            ) {
                viewModel.startAgain()
            }
        } message: {
            Text(
                NSLocalizedString(
                    "tasbih_completion_message",
                    comment: ""
                )
            )
        }
        .onAppear {
            guard !isPresented else { return }
            isPresented = true
        }
        .onDisappear {
            isPresented = false
        }
        .navigationTitle(
            NSLocalizedString("tasbih_tab_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onOpenSettings()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func entrance<Content: View>(
        delay: Double,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .opacity(isPresented ? 1 : 0)
            .offset(y: isPresented ? 0 : 14)
            .animation(
                .easeOut(duration: 0.45).delay(delay),
                value: isPresented
            )
    }

    private var countingContent: some View {
        Group {
            if viewModel.isFreeCount {
                freeCountingContent
            } else {
                regularCountingContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            increment()
        }
    }

    private var regularCountingContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 10)

            dhikr
                .padding(.horizontal, 24)

            phrasePicker
                .padding(.top, 10)

            Spacer(minLength: 8)

            countView

            Spacer(minLength: 12)

            TasbihBeadProgressView(
                progress: viewModel.progress,
                count: viewModel.count,
                target: viewModel.target
            )
            .frame(height: 92)
            .padding(.horizontal, 18)

            Text(
                NSLocalizedString(
                    "tasbih_tap_instruction",
                    comment: ""
                )
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.textGray)
            .padding(.top, 2)

            Spacer(minLength: 8)
        }
    }

    private var phrasePicker: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.phrases.indices, id: \.self) { index in
                Button {
                    viewModel.selectPhrase(index)
                } label: {
                    Text(
                        NSLocalizedString(
                            viewModel.phrases[index].nameKey,
                            comment: ""
                        )
                    )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        index == viewModel.phraseIndex
                            ? .title
                            : .textGray
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        index == viewModel.phraseIndex
                            ? Color.lightGreen.opacity(0.14)
                            : Color.backgroundGray
                    )
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(
                                index == viewModel.phraseIndex
                                    ? Color.lightGreen.opacity(0.35)
                                    : Color.textGray.opacity(0.08),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
    }

    private var freeCountingContent: some View {
        VStack(spacing: 16) {
            Spacer()
            countView
            Spacer()
            Text(
                NSLocalizedString(
                    "tasbih_tap_instruction",
                    comment: ""
                )
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.textGray)
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 24)
    }

    private var background: some View {
        ZStack {
            Color.appBackground

            LinearGradient(
                colors: [
                    Color.lightGreen.opacity(0.18),
                    Color.lightGreen.opacity(0.06),
                    Color.appBackground,
                    Color.backgroundGray.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.lightGreen.opacity(0.13))
                .frame(width: 320, height: 320)
                .blur(radius: 45)
                .offset(y: -120)
        }
        .ignoresSafeArea()
    }

    private var dhikr: some View {
        VStack(spacing: 7) {
            Text(viewModel.currentPhrase.arabic)
                .font(.amiriBold(size: 38))
                .foregroundColor(.title)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            Text(
                NSLocalizedString(
                    viewModel.currentPhrase.nameKey,
                    comment: ""
                )
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.textGray)
        }
        .animation(
            .easeInOut(duration: 0.25),
            value: viewModel.phraseIndex
        )
    }

    private var countView: some View {
        VStack(spacing: 0) {
            Text("\(viewModel.displayedCount)")
                .font(
                    .system(
                        size: 118,
                        weight: .light,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .foregroundColor(.title)
                .contentTransition(
                    .numericText(value: Double(viewModel.displayedCount))
                )
                .scaleEffect(pulse ? 1.04 : 1)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.6),
                    value: pulse
                )

            Text(
                viewModel.isFreeCount
                    ? NSLocalizedString(
                        "tasbih_free_count_active",
                        comment: ""
                    )
                    : String(
                        format: NSLocalizedString(
                            "tasbih_count_of_format",
                            comment: ""
                        ),
                        viewModel.target
                    )
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.textGray)
        }
    }

    private var freeCountButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleFreeCount()
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "infinity")
                    .font(.system(size: 10, weight: .semibold))

                Text(
                    NSLocalizedString(
                        "tasbih_free_count",
                        comment: ""
                    )
                )
                .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(
                viewModel.isFreeCount ? .white : .title
            )
            .padding(.horizontal, 11)
            .frame(height: 46)
            .background(
                viewModel.isFreeCount
                    ? Color.lightGreen
                    : Color.backgroundGray
            )
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.textGray.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.decrement()
            } label: {
                Text("-1")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        viewModel.displayedCount > 0
                            ? .title
                            : .textGray.opacity(0.45)
                    )
                    .frame(width: 58, height: 46)
                    .background(Color.backgroundGray)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(
                                Color.textGray.opacity(0.12),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canDecrement)

            Spacer()

            freeCountButton

            Button {
                viewModel.resetCurrent()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))

                    Text(
                        NSLocalizedString("tasbih_reset", comment: "")
                    )
                    .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.title)
                .padding(.horizontal, 18)
                .frame(height: 46)
                .background(Color.backgroundGray)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.textGray.opacity(0.12), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    private func increment() {
        guard !viewModel.isCompleting else { return }

        withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
            pulse = true
        }
        viewModel.increment()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            pulse = false
        }
    }
}
