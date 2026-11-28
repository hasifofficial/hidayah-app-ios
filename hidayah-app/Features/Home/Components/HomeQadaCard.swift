//
//  HomeQadaCard.swift
//  hidayah-app
//

import SwiftUI

/// The Qada fasts still owed, on Home under the tracker card. Home only
/// shows it while at least one fast is left.
struct HomeQadaCard: View {
    let ledger: QadaLedger
    let daysUntilRamadan: Int?
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [QadaPalette.nightTop, QadaPalette.nightBottom],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    QadaMoonView(phase: ledger.progress)
                        .frame(width: 40, height: 40)
                }
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("qada_header_title", comment: ""))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.title)

                    Text(
                        HomeQadaSummary.message(
                            remaining: ledger.totalRemaining,
                            madeUp: ledger.totalMadeUp,
                            owed: ledger.totalOwed
                        )
                    )
                    .font(.system(size: 13))
                    .foregroundColor(.title.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                    if let days = daysUntilRamadan {
                        deadlinePill(days)
                    }
                }
                // Takes exactly the room between the moon and the arrow, so
                // wrapped text can't push the card wider than the screen.
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textGray)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.backgroundGray)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.lightGreen.opacity(0.08), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    /// When the next Ramadan begins; orange in its last month, when the
    /// owed days are due.
    private func deadlinePill(_ days: Int) -> some View {
        let color: Color = HomeQadaSummary.isDeadlineNear(days) ? .orange : .lightGreen

        return HStack(spacing: 3) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 10, weight: .semibold))

            Text(HomeQadaSummary.deadline(days: days))
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.14), in: Capsule())
    }
}

/// The wording on Home's Qada card.
enum HomeQadaSummary {
    /// Days before Ramadan when the deadline pill turns orange.
    static let nearDeadlineDays = 30

    static func message(remaining: Int, madeUp: Int, owed: Int) -> String {
        let left = String(
            format: NSLocalizedString(
                remaining == 1 ? "home_qada_left_one" : "home_qada_left",
                comment: ""
            ),
            remaining
        )
        guard madeUp > 0 else { return left }

        return left + " · " + String(
            format: NSLocalizedString("home_qada_done_format", comment: ""),
            madeUp,
            owed
        )
    }

    static func deadline(days: Int) -> String {
        switch days {
        case ...0:
            return NSLocalizedString("home_qada_deadline_today", comment: "")
        case 1:
            return NSLocalizedString("home_qada_deadline_tomorrow", comment: "")
        default:
            return String(
                format: NSLocalizedString("home_qada_deadline_days", comment: ""),
                days
            )
        }
    }

    static func isDeadlineNear(_ days: Int) -> Bool {
        days <= nearDeadlineDays
    }
}
