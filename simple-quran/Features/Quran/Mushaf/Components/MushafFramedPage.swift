//
//  MushafFramedPage.swift
//  simple-quran
//

import SwiftUI

/// The sizes a framed page is built from, shared by the page and the pagers
/// that lay pages out.
enum MushafPageMetrics {
    /// Width over height of the bundled page images (1920 × 3106).
    static let pageAspect: CGFloat = 1920.0 / 3106.0
    /// Space around the frame.
    static let margin: CGFloat = 10
    /// The double rule's width, up to the inner hairline.
    static let frameWidth: CGFloat = 6
    /// Space between the inner hairline and the text.
    static let innerPadding: CGFloat = 8
    static let runningHeadHeight: CGFloat = 26
    static let footHeight: CGFloat = 36

    /// Everything around the image across one side.
    static var sideInset: CGFloat {
        margin + frameWidth + innerPadding
    }

    /// The image size that fits `size` with room for the frame, the running
    /// head and the foot.
    static func imageSize(fitting size: CGSize) -> CGSize {
        let width = max(size.width - 2 * sideInset, 1)
        let height = max(
            size.height - 2 * sideInset - runningHeadHeight - footHeight,
            1
        )
        let fittedHeight = min(height, width / pageAspect)
        return CGSize(width: fittedHeight * pageAspect, height: fittedHeight)
    }

    /// The height a page needs when it is `width` wide, for scrolling
    /// pages one under another.
    static func height(forWidth width: CGFloat) -> CGFloat {
        let imageWidth = max(width - 2 * sideInset, 1)
        return imageWidth / pageAspect
            + runningHeadHeight
            + footHeight
            + 2 * sideInset
    }
}

/// One Mushaf page as printed: the page image in a green double-ruled
/// frame, with a running head, a star medallion holding the page number,
/// margin marks where a quarter hizb begins, and a bookmark ribbon.
///
/// The image is a template tinted with the text colour, so it reads in
/// dark mode too.
struct MushafFramedPage: View {
    /// Which physical side of the page faces the binding in a spread.
    enum Spine {
        case none
        case left
        case right
    }

    let page: Int
    let size: CGSize
    let maxPixelWidth: CGFloat
    var spine: Spine = .none
    /// Stretches the frame to fill `size`, with the page text centred
    /// inside, rather than hugging the text. Spreads use it so the open
    /// book fills the screen.
    var fillsSpace = false
    let viewModel: MushafViewModel

    @State private var image: CGImage?

    var body: some View {
        let imageSize = MushafPageMetrics.imageSize(fitting: size)

        framedContent(imageSize: imageSize)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleChrome()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(viewModel.accessibilityLabel(forPage: page))
            .accessibilityAction(named: bookmarkActionName) {
                viewModel.toggleBookmark(page: page)
            }
            // Centred on the top rule, where the running head leaves a gap
            // between the juz and the surah name. Added after the page's
            // accessibility element so it stays its own button.
            .overlay(alignment: .top) {
                MushafBookmarkRibbon(
                    isBookmarked: viewModel.isBookmarked(page: page),
                    page: page
                ) {
                    viewModel.toggleBookmark(page: page)
                }
            }
            .frame(width: size.width, height: size.height)
        .environment(\.layoutDirection, .leftToRight)
        .task(id: page) {
            image = await viewModel.image(forPage: page, maxPixelWidth: maxPixelWidth)
        }
    }

    private func framedContent(imageSize: CGSize) -> some View {
        VStack(spacing: 0) {
            runningHead
                .frame(height: MushafPageMetrics.runningHeadHeight)

            pageImage
                .frame(width: imageSize.width, height: imageSize.height)
                .frame(maxWidth: .infinity, maxHeight: fillsSpace ? .infinity : nil)

            MushafStarMedallion(text: viewModel.arabicNumber(page))
                .frame(height: MushafPageMetrics.footHeight)
        }
        .frame(width: fillsSpace ? nil : imageSize.width)
        .padding(MushafPageMetrics.frameWidth + MushafPageMetrics.innerPadding)
        .frame(
            width: fillsSpace ? max(size.width - 2 * MushafPageMetrics.margin, 0) : nil,
            height: fillsSpace ? max(size.height - 2 * MushafPageMetrics.margin, 0) : nil
        )
        .background(MushafFrame())
        .overlay(alignment: markerAlignment) {
            quarterMarkers
        }
    }

    /// "Juz N" on the left and the calligraphic surah names on the right, as
    /// in the head of a printed page.
    private var runningHead: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(
                    String(
                        format: NSLocalizedString("quran_mushaf_juz_format", comment: ""),
                        viewModel.juz(onPage: page)
                    )
                )
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.lightGreen)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    ForEach(viewModel.surahs(onPage: page), id: \.self) { surah in
                        if let ligature = Font.surahNameLigature(for: surah) {
                            Text(ligature)
                                .font(.surahNameFont(size: 24))
                                .foregroundColor(.lightGreen)
                        }
                    }
                }
                // The first surah on the right, as Arabic reads.
                .environment(\.layoutDirection, .rightToLeft)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(Color.lightGreen.opacity(0.45))
                .frame(height: 0.5)
        }
    }

    @ViewBuilder
    private var pageImage: some View {
        if let image {
            Image(decorative: image, scale: 1)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.primary)
        } else {
            VStack(spacing: 14) {
                ForEach(0..<8, id: \.self) { _ in
                    ShimmerBar()
                        .frame(height: 14)
                }
            }
            .padding(.vertical, 24)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private var quarterMarkers: some View {
        let quarters = viewModel.quarterStarts(onPage: page)
        if !quarters.isEmpty {
            VStack(spacing: 6) {
                ForEach(quarters, id: \.self) { quarter in
                    MushafQuarterMarker(quarter: quarter, hizbText: viewModel.arabicNumber)
                        .padding(2)
                        // Masks the frame rule behind it, in the colour
                        // the page sits on.
                        .background(
                            spine == .none ? Color.appBackground : MushafSpreadView.paper,
                            in: Circle()
                        )
                }
            }
            .padding(.top, MushafPageMetrics.runningHeadHeight + 24)
            .offset(x: markerOffset)
        }
    }

    /// The outer margin: the right page's right edge and the left page's
    /// left edge. A single page follows the same rule, odd pages being right
    /// pages.
    private var outerEdgeIsRight: Bool {
        switch spine {
        case .left:
            return true
        case .right:
            return false
        case .none:
            return !page.isMultiple(of: 2)
        }
    }

    private var markerAlignment: Alignment {
        outerEdgeIsRight ? .topTrailing : .topLeading
    }

    /// Straddles the outer double rule.
    private var markerOffset: CGFloat {
        let shift: CGFloat = 8
        return outerEdgeIsRight ? shift : -shift
    }

    private var bookmarkActionName: String {
        NSLocalizedString(
            viewModel.isBookmarked(page: page)
                ? "quran_mushaf_remove_bookmark"
                : "quran_mushaf_add_bookmark",
            comment: ""
        )
    }
}

/// A two-page spread on a sheet of paper, the pages meeting at a soft
/// spine shadow like an open book.
struct MushafSpreadView: View {
    /// Right page first.
    let pages: [Int]
    let size: CGSize
    let displayScale: CGFloat
    let viewModel: MushafViewModel

    var body: some View {
        // The open book fills the screen; each page's text stays at its
        // printed proportions, centred in its frame.
        let sheetSize = CGSize(
            width: max((size.width - 2 * Self.canvasPadding) / 2, 0),
            height: max(size.height - 2 * Self.canvasPadding, 0)
        )

        // The parent pager is right-to-left, so the first page lands on the
        // right.
        HStack(spacing: 0) {
            ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                let spine: MushafFramedPage.Spine = index == 0 ? .left : .right

                MushafFramedPage(
                    page: page,
                    size: sheetSize,
                    maxPixelWidth: sheetSize.width * displayScale,
                    spine: pages.count == 2 ? spine : .none,
                    fillsSpace: true,
                    viewModel: viewModel
                )
                .background {
                    sheet(spine: pages.count == 2 ? spine : .none)
                }
            }
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .frame(width: size.width, height: size.height)
    }

    static let canvasPadding: CGFloat = 12

    /// White paper in light mode; in dark mode a lifted grey, so the spine
    /// shadow still shows against it.
    static let paper = Color(uiColor: .tertiarySystemBackground)

    /// The desk the open book lies on.
    static let canvas = Color(uiColor: .systemGroupedBackground)

    private func sheet(spine: MushafFramedPage.Spine) -> some View {
        let radius: CGFloat = 12
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: spine == .left ? 0 : radius,
            bottomLeadingRadius: spine == .left ? 0 : radius,
            bottomTrailingRadius: spine == .right ? 0 : radius,
            topTrailingRadius: spine == .right ? 0 : radius,
            style: .continuous
        )

        return shape
            .fill(Self.paper)
            .overlay {
                if spine != .none {
                    spineShadow(spine)
                        .clipShape(shape)
                }
            }
            // Pages are laid out left to right inside, so the edges above
            // are physical.
            .environment(\.layoutDirection, .leftToRight)
            .accessibilityHidden(true)
    }

    /// Darkest at the binding and fading out over about an eighth of the
    /// page, with a hairline seam.
    private func spineShadow(_ spine: MushafFramedPage.Spine) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width * 0.12
            let gradient = LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.16), location: 0),
                    .init(color: .black.opacity(0.05), location: 0.4),
                    .init(color: .clear, location: 1)
                ],
                startPoint: spine == .left ? .leading : .trailing,
                endPoint: spine == .left ? .trailing : .leading
            )

            ZStack(alignment: spine == .left ? .leading : .trailing) {
                Rectangle()
                    .fill(gradient)
                    .frame(width: width)

                Rectangle()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 0.5)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: spine == .left ? .leading : .trailing
            )
        }
    }
}
