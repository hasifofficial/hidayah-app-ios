//
//  QadaYearCard.swift
//  hidayah-app
//

import SwiftUI

/// One Ramadan: a bead for every day owed, filled in as each is made up.
struct QadaYearCard: View {
    let year: QadaYear
    let title: String
    let detail: String
    let isNext: Bool
    let nextLabel: String
    let onTap: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 24, maximum: 28), spacing: 7)]

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 10) {
                    IllustrationImage(
                        name: year.isComplete ? Illustration.qadaMoonFull : Illustration.qadaMoon,
                        size: 46
                    )
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: year.isComplete)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.title)

                        Text(detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(year.isComplete ? .lightGreen : .textGray)
                    }

                    Spacer(minLength: 8)

                    if isNext {
                        Text(nextLabel)
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .foregroundColor(.lightGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.lightGreen.opacity(0.14), in: Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textGray.opacity(0.6))
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: 7) {
                    ForEach(0..<year.owedDays, id: \.self) { index in
                        bead(isFilled: index < year.madeUpDays)
                    }
                }
                .accessibilityHidden(true)
            }
            .padding(16)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isNext ? Color.lightGreen.opacity(0.35) : Color.textGray.opacity(0.06),
                        lineWidth: isNext ? 1.5 : 1
                    )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private func bead(isFilled: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    isFilled
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.lightGreen.opacity(0.85), Color.lightGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.lightGreen.opacity(0.08))
                )

            Circle()
                .strokeBorder(
                    isFilled ? Color.clear : Color.lightGreen.opacity(0.45),
                    style: StrokeStyle(lineWidth: 1.5, dash: [3, 2.5])
                )

            if isFilled {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 24, height: 24)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isFilled)
    }
}
