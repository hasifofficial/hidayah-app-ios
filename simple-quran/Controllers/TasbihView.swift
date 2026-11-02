//
//  TasbihView.swift
//  simple-quran
//

import SwiftUI
import UIKit

private struct TasbihPhrase {
    let nameKey: String
    let arabic: String
}

struct TasbihView: View {
    private let phrases: [TasbihPhrase] = [
        TasbihPhrase(
            nameKey: "tasbih_phrase_1_title",
            arabic: "سُبْحَانَ ٱللَّٰهِ"
        ),
        TasbihPhrase(
            nameKey: "tasbih_phrase_2_title",
            arabic: "ٱلْحَمْدُ لِلَّٰهِ"
        ),
        TasbihPhrase(
            nameKey: "tasbih_phrase_3_title",
            arabic: "ٱللَّٰهُ أَكْبَرُ"
        )    ]

    @State private var phraseIndex = 0
    @State private var count = 0
    @State private var freeCountValue = 0
    @State private var isFreeCount = false
    @State private var isCompleting = false
    @State private var pulse = false
    @State private var isPresented = false
    @State private var showCompletion = false

    private let target = 33

    private var currentPhrase: TasbihPhrase {
        phrases[phraseIndex]
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(count) / Double(target), 1)
    }

    private var displayedCount: Int {
        isFreeCount ? freeCountValue : count
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                entrance(delay: 0) {
                    header
                        .padding(.top, 8)
                }

                entrance(delay: 0.08) {
                    countingContent
                }

                entrance(delay: 0.16) {
                    controls
                        .padding(.top, 16)
                        .padding(.bottom, 96)
                }
            }
        }
        .alert(
            NSLocalizedString("tasbih_completion_title", comment: ""),
            isPresented: $showCompletion
        ) {
            Button(
                NSLocalizedString("tasbih_start_again", comment: "")
            ) {
                startAgain()
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
        .toolbar(.hidden, for: .navigationBar)
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
            if isFreeCount {
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

            TasbihBeadsView(
                progress: progress,
                count: count,
                target: target
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
            ForEach(phrases.indices, id: \.self) { index in
                Button {
                    selectPhrase(index)
                } label: {
                    HStack(spacing: 5) {
                        Text("\(index + 1)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(
                                index == phraseIndex
                                    ? .lightGreen
                                    : .textGray
                            )

                        Text(
                            NSLocalizedString(
                                phrases[index].nameKey,
                                comment: ""
                            )
                        )
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(
                            index == phraseIndex
                                ? .title
                                : .textGray
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(
                        index == phraseIndex
                            ? Color.lightGreen.opacity(0.14)
                            : Color.backgroundGray
                    )
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(
                                index == phraseIndex
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

    private var header: some View {
        HStack {
            Text(
                NSLocalizedString("tasbih_header_title", comment: "")
            )
            .font(.system(size: 12, weight: .semibold))
            .tracking(2)
            .foregroundColor(.textGray)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFreeCount.toggle()
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
                    isFreeCount ? .white : .title
                )
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    isFreeCount
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
        .padding(.horizontal, 24)
    }

    private var dhikr: some View {
        VStack(spacing: 7) {
            Text(currentPhrase.arabic)
                .font(.amiriBold(size: 38))
                .foregroundColor(.title)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            Text(
                "\(phraseIndex + 1). \(NSLocalizedString(currentPhrase.nameKey, comment: ""))"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.textGray)
        }
        .animation(.easeInOut(duration: 0.25), value: phraseIndex)
    }

    private var countView: some View {
        VStack(spacing: 0) {
            Text("\(displayedCount)")
                .font(
                    .system(
                        size: 118,
                        weight: .light,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .foregroundColor(.title)
                .contentTransition(.numericText(value: Double(displayedCount)))
                .scaleEffect(pulse ? 1.04 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pulse)

            Text(
                isFreeCount
                    ? NSLocalizedString("tasbih_free_count_active", comment: "")
                    : String(
                        format: NSLocalizedString(
                            "tasbih_count_of_format",
                            comment: ""
                        ),
                        target
                    )
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.textGray)
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                decrement()
            } label: {
                Text("-1")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        displayedCount > 0
                            ? .title
                            : .textGray.opacity(0.45)
                    )
                    .frame(width: 58, height: 46)
                    .background(Color.backgroundGray)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.textGray.opacity(0.12), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(displayedCount == 0 || isCompleting)

            Spacer()

            Button {
                resetCurrent()
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
        guard !isCompleting else { return }

        withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
            pulse = true
        }
        HapticFeedback.tap()

        if isFreeCount {
            freeCountValue += 1
        } else {
            count += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            pulse = false
        }

        guard !isFreeCount, count >= target else { return }

        completeRound()
    }

    private func completeRound() {
        isCompleting = true
        HapticFeedback.success()

        if phraseIndex == phrases.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCompletion = true
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.3)) {
                count = 0
                phraseIndex += 1
                isCompleting = false
            }
        }
    }

    private func startAgain() {
        HapticFeedback.success()

        withAnimation(.easeInOut(duration: 0.25)) {
            count = 0
            phraseIndex = 0
            isFreeCount = false
            showCompletion = false
            isCompleting = false
        }
    }

    private func selectPhrase(_ index: Int) {
        guard !isCompleting, index != phraseIndex else { return }

        HapticFeedback.selection()

        withAnimation(.easeInOut(duration: 0.22)) {
            phraseIndex = index
            count = 0
        }
    }

    private func decrement() {
        guard !isCompleting, displayedCount > 0 else { return }
        HapticFeedback.tap()

        if isFreeCount {
            freeCountValue -= 1
        } else {
            count -= 1
        }
    }

    private func resetCurrent() {
        guard !isCompleting else { return }
        HapticFeedback.tap()
        withAnimation(.easeInOut(duration: 0.2)) {
            if isFreeCount {
                freeCountValue = 0
            } else {
                count = 0
            }
        }
    }

}

private struct TasbihBeadsView: View {
    let progress: Double
    let count: Int
    let target: Int

    @State private var highlightedBead: Int?
    @State private var isPulsing = false

    private let beadCount = 9
    private let activeColor = Color.lightGreen
    private let highlightColor = Color(red: 0.82, green: 0.69, blue: 0.38)

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            let filledCount = min(
                beadCount,
                Int(ceil(progress * Double(beadCount)))
            )

            ZStack {
                ForEach(0..<beadCount, id: \.self) { index in
                    let t = Double(index) / Double(beadCount - 1)
                    let point = beadPoint(
                        t: t,
                        width: width,
                        height: height
                    )
                    let filled = index >= beadCount - filledCount
                    let isHighlighted = highlightedBead == index

                    Circle()
                        .fill(
                            isHighlighted
                                ? highlightColor
                                : (filled
                                    ? activeColor
                                    : Color.lightGreen.opacity(0.16))
                        )
                        .frame(
                            width: isHighlighted ? 36 : 30,
                            height: isHighlighted ? 36 : 30
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    isHighlighted
                                        ? highlightColor.opacity(0.9)
                                        : (filled
                                            ? activeColor.opacity(0.9)
                                            : Color.textGray.opacity(0.08)),
                                    lineWidth: 1
                                )
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    highlightColor.opacity(
                                        isHighlighted ? 0.45 : 0
                                    ),
                                    lineWidth: 2
                                )
                                .scaleEffect(isHighlighted ? 1.45 : 1)
                        }
                        .shadow(
                            color: isHighlighted
                                ? highlightColor.opacity(0.55)
                                : (filled ? activeColor.opacity(0.25) : .clear),
                            radius: isHighlighted ? 12 : 5
                        )
                        .scaleEffect(
                            isHighlighted && isPulsing ? 1.16 : 1
                        )
                        .position(point)
                        .animation(
                            .spring(
                                response: 0.28,
                                dampingFraction: 0.55
                            ),
                            value: highlightedBead
                        )
                        .animation(
                            .spring(
                                response: 0.2,
                                dampingFraction: 0.5
                            ),
                            value: isPulsing
                        )
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: filled
                        )
                }

                if let highlightedBead {
                    let t = Double(highlightedBead)
                        / Double(beadCount - 1)
                    let point = beadPoint(
                        t: t,
                        width: width,
                        height: height
                    )

                    Circle()
                        .fill(highlightColor.opacity(0.30))
                        .frame(width: 44, height: 44)
                        .blur(radius: 9)
                        .position(point)
                        .allowsHitTesting(false)
                        .animation(
                            .spring(
                                response: 0.32,
                                dampingFraction: 0.7
                            ),
                            value: highlightedBead
                        )
                }
            }
        }
        .onChange(of: count) { _, newCount in
            animateBead(for: newCount)
        }
    }

    private func animateBead(for newCount: Int) {
        guard newCount > 0, target > 0 else {
            highlightedBead = nil
            isPulsing = false
            return
        }

        let filledCount = min(
            beadCount,
            Int(
                ceil(
                    (Double(newCount) / Double(target))
                        * Double(beadCount)
                )
            )
        )
        let index = max(0, beadCount - filledCount)

        highlightedBead = index
        isPulsing = false

        withAnimation(
            .spring(response: 0.22, dampingFraction: 0.45)
        ) {
            isPulsing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.2)) {
                if highlightedBead == index {
                    isPulsing = false
                }
            }
        }
    }

    private func beadPoint(
        t: Double,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let x = width * (0.07 + 0.86 * t)
        let curve = pow((t - 0.5) * 2, 2)
        let y = height * (0.30 + 0.52 * curve)
        return CGPoint(x: x, y: y)
    }
}

private enum HapticFeedback {
    static let impact = UIImpactFeedbackGenerator(style: .light)
    static let notification = UINotificationFeedbackGenerator()

    static func tap() {
        impact.prepare()
        impact.impactOccurred(intensity: 0.8)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func success() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }
}
