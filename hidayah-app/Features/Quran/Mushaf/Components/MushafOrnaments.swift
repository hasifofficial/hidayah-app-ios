//
//  MushafOrnaments.swift
//  hidayah-app
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

/// The page border, in the manner of an illuminated Mushaf: a gold double
/// rule, a band of small gold stars and green diamonds, a Rub el Hizb star
/// in each corner, and a green double rule inside.
struct MushafFrame: View {
    var body: some View {
        Canvas { context, size in
            MushafBorderPainter.draw(in: &context, size: size)
        }
        .accessibilityHidden(true)
    }
}

/// Draws the page border. Every inset is measured from the outer edge and
/// fits inside `MushafPageMetrics.frameWidth`.
enum MushafBorderPainter {
    static let gold = Color.mushafGold
    static let green = Color.lightGreen

    /// Where the band of motifs sits, between the gold and green rules.
    static let bandOuter: CGFloat = 4.5
    static let bandInner: CGFloat = 13.5
    static var bandCenter: CGFloat { (bandOuter + bandInner) / 2 }

    /// The distance between motifs along an edge; the real step stretches a
    /// little so each edge holds a whole number of them.
    static let motifSpacing: CGFloat = 9
    static let starRadius: CGFloat = 3.4
    static let diamondRadius: CGFloat = 1.9
    static let cornerRadius: CGFloat = 7

    static func draw(in context: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        guard rect.width > 4 * bandInner, rect.height > 4 * bandInner else { return }

        // Gold double rule outside.
        stroke(rect, inset: 0.75, corner: 5, color: gold, width: 1.5, in: &context)
        stroke(rect, inset: 3.4, corner: 4, color: gold, width: 0.75, in: &context)

        // A faint green thread through the band ties the motifs together.
        stroke(rect, inset: bandCenter, corner: 3, color: green.opacity(0.35), width: 0.5, in: &context)

        // Green double rule inside.
        stroke(rect, inset: bandInner + 0.4, corner: 3, color: green, width: 0.75, in: &context)
        stroke(
            rect,
            inset: MushafPageMetrics.frameWidth - 0.25,
            corner: 2,
            color: green.opacity(0.7),
            width: 0.5,
            in: &context
        )

        drawEdgeMotifs(in: rect, context: &context)

        for corner in cornerCenters(in: rect) {
            drawRubElHizb(at: corner, radius: cornerRadius, in: &context)
        }
    }

    static func cornerCenters(in rect: CGRect) -> [CGPoint] {
        let c = bandCenter
        return [
            CGPoint(x: rect.minX + c, y: rect.minY + c),
            CGPoint(x: rect.maxX - c, y: rect.minY + c),
            CGPoint(x: rect.minX + c, y: rect.maxY - c),
            CGPoint(x: rect.maxX - c, y: rect.maxY - c)
        ]
    }

    /// Alternating stars and diamonds along each edge, between the corner
    /// stars, starting and ending on a star.
    static func drawEdgeMotifs(in rect: CGRect, context: inout GraphicsContext) {
        let c = bandCenter
        let clearance = cornerRadius + 4
        let edges: [(CGPoint, CGPoint)] = [
            (CGPoint(x: rect.minX + c + clearance, y: rect.minY + c), CGPoint(x: rect.maxX - c - clearance, y: rect.minY + c)),
            (CGPoint(x: rect.minX + c + clearance, y: rect.maxY - c), CGPoint(x: rect.maxX - c - clearance, y: rect.maxY - c)),
            (CGPoint(x: rect.minX + c, y: rect.minY + c + clearance), CGPoint(x: rect.minX + c, y: rect.maxY - c - clearance)),
            (CGPoint(x: rect.maxX - c, y: rect.minY + c + clearance), CGPoint(x: rect.maxX - c, y: rect.maxY - c - clearance))
        ]

        for (start, end) in edges {
            for (index, point) in motifPoints(from: start, to: end).enumerated() {
                if index.isMultiple(of: 2) {
                    let star = MushafStarShape(innerRatio: 0.55).path(
                        in: CGRect(
                            x: point.x - starRadius,
                            y: point.y - starRadius,
                            width: starRadius * 2,
                            height: starRadius * 2
                        )
                    )
                    context.fill(star, with: .color(gold))
                } else {
                    context.fill(diamond(at: point, radius: diamondRadius), with: .color(green))
                }
            }
        }
    }

    /// Evenly spaced points from `start` to `end`, an odd number of them so
    /// both ends get a star.
    static func motifPoints(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        let length = hypot(end.x - start.x, end.y - start.y)
        guard length > 0 else { return [start] }

        var count = Int(length / motifSpacing) + 1
        if count.isMultiple(of: 2) {
            count += 1
        }
        guard count > 1 else { return [start] }

        return (0..<count).map { index in
            let t = CGFloat(index) / CGFloat(count - 1)
            return CGPoint(
                x: start.x + (end.x - start.x) * t,
                y: start.y + (end.y - start.y) * t
            )
        }
    }

    /// The Rub el Hizb: two overlapping gold squares, a green star inside
    /// and a gold dot at the centre. It covers the rules beneath it.
    static func drawRubElHizb(at center: CGPoint, radius: CGFloat, in context: inout GraphicsContext) {
        let side = radius * 2 / sqrt(2)
        let square = CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side)

        let upright = Path(square)
        let turned = Path(square).applying(
            CGAffineTransform(translationX: center.x, y: center.y)
                .rotated(by: .pi / 4)
                .translatedBy(x: -center.x, y: -center.y)
        )
        context.fill(upright, with: .color(gold))
        context.fill(turned, with: .color(gold))

        let innerRadius = radius * 0.55
        let innerStar = MushafStarShape(innerRatio: 0.6).path(
            in: CGRect(
                x: center.x - innerRadius,
                y: center.y - innerRadius,
                width: innerRadius * 2,
                height: innerRadius * 2
            )
        )
        context.fill(innerStar, with: .color(green))

        let dot = radius * 0.16
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - dot, y: center.y - dot, width: dot * 2, height: dot * 2)),
            with: .color(gold)
        )
    }

    static func diamond(at center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - radius))
        path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
        path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
        path.closeSubpath()
        return path
    }

    private static func stroke(
        _ rect: CGRect,
        inset: CGFloat,
        corner: CGFloat,
        color: Color,
        width: CGFloat,
        in context: inout GraphicsContext
    ) {
        let path = Path(
            roundedRect: rect.insetBy(dx: inset, dy: inset),
            cornerRadius: corner,
            style: .continuous
        )
        context.stroke(path, with: .color(color), lineWidth: width)
    }
}

/// The page number in a gold star, at the foot of the page.
struct MushafStarMedallion: View {
    let text: String

    var body: some View {
        ZStack {
            MushafStarShape()
                .stroke(Color.mushafGold, lineWidth: 1.2)

            MushafStarShape()
                .stroke(Color.mushafGold.opacity(0.35), lineWidth: 0.6)
                .padding(4)

            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.mushafGold)
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
    /// gold and green ornament.
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
