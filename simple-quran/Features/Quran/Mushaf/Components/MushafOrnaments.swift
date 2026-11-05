//
//  MushafOrnaments.swift
//  simple-quran
//

import SwiftUI

/// An eight-pointed star, the shape printed Mushafs use for page numbers
/// and hizb markers.
struct MushafStarShape: Shape {
    /// How far the inner corners sit from the centre, as a share of the
    /// radius.
    var innerRatio: CGFloat = 0.76

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        var path = Path()

        for index in 0..<16 {
            let radius = index.isMultiple(of: 2) ? outer : inner
            let angle = Double(index) * .pi / 8 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle))
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

/// The page border: a double rule outside and a hairline inside, in the
/// brand green.
struct MushafFrame: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Color.lightGreen, lineWidth: 1.5)

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(Color.lightGreen, lineWidth: 0.75)
                .padding(3)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(Color.lightGreen.opacity(0.7), lineWidth: 0.5)
                .padding(MushafPageMetrics.frameWidth)
        }
        .accessibilityHidden(true)
    }
}

/// The page number in a star, at the foot of the page.
struct MushafStarMedallion: View {
    let text: String

    var body: some View {
        ZStack {
            MushafStarShape()
                .stroke(Color.lightGreen, lineWidth: 1.2)

            MushafStarShape()
                .stroke(Color.lightGreen.opacity(0.35), lineWidth: 0.6)
                .padding(4)

            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.lightGreen)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(6)
        }
        .frame(width: 30, height: 30)
        .accessibilityHidden(true)
    }
}

/// The margin mark where a quarter hizb begins: the hizb number on a new
/// hizb, otherwise ¼, ½ or ¾.
struct MushafQuarterMarker: View {
    /// The quarter, numbered from 1.
    let quarter: Int
    let hizbText: (Int) -> String

    var body: some View {
        ZStack {
            MushafStarShape(innerRatio: 0.7)
                .fill(Color.lightGreen)

            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(4)
        }
        .frame(width: 20, height: 20)
        .accessibilityHidden(true)
    }

    private var label: String {
        let position = (quarter - 1) % MushafLayout.quartersPerHizb
        switch position {
        case 0:
            return hizbText((quarter - 1) / MushafLayout.quartersPerHizb + 1)
        case 1:
            return "¼"
        case 2:
            return "½"
        default:
            return "¾"
        }
    }
}

/// A ribbon hanging from the top of the page: filled red when the page is
/// bookmarked, a faint outline otherwise.
struct MushafBookmarkRibbon: View {
    /// Red like a printed Mushaf's ribbon marker, and set apart from the
    /// green ornament.
    static let color = Color.red

    let isBookmarked: Bool
    let page: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RibbonShape()
                .fill(isBookmarked ? Self.color : Color.clear)
                .overlay {
                    RibbonShape()
                        .stroke(
                            isBookmarked
                                ? Self.color
                                : Color.textGray.opacity(0.45),
                            lineWidth: 1
                        )
                }
                .frame(width: 14, height: 26)
                .frame(width: 44, height: 44, alignment: .top)
                .contentShape(Rectangle())
                .animation(.spring(duration: 0.25), value: isBookmarked)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            String(
                format: NSLocalizedString(
                    isBookmarked
                        ? "quran_mushaf_remove_bookmark_format"
                        : "quran_mushaf_add_bookmark_format",
                    comment: ""
                ),
                page
            )
        )
    }

    private struct RibbonShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width * 0.5))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}
