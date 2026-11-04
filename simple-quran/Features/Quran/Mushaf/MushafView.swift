//
//  MushafView.swift
//  simple-quran
//

import SwiftUI

/// The Quran as Mushaf pages, swiped right to left like a printed copy.
/// On a wide screen, such as an unfolded iPhone Duo or an iPad in landscape,
/// it shows two pages side by side like an open book.
struct MushafView: View {
    /// A spread needs room for two readable pages: at least 600 points
    /// across (an unfolded iPhone Duo is about 700), on a screen not much
    /// taller than wide. A phone held upright keeps one page.
    nonisolated static func showsSpread(in size: CGSize) -> Bool {
        size.height > 0 && size.width >= 600 && size.width / size.height >= 0.6
    }

    @Bindable var viewModel: MushafViewModel

    @Environment(\.displayScale) private var displayScale

    @State private var showingReadingSettings = false

    @AppStorage(
        Storage.StorageKey.mushafShowsSpread.rawValue,
        store: Storage.userDefaults
    ) private var allowsSpread = true

    var body: some View {
        Group {
            if let layout = viewModel.layout {
                reader(layout)
            } else if viewModel.loadError != nil {
                errorState
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.appBackground)
        .navigationTitle(
            viewModel.surahs(onPage: viewModel.currentPage)
                .map(viewModel.surahName)
                .joined(separator: " · ")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingReadingSettings = true
                } label: {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(
                    NSLocalizedString("quran_reading_settings_title", comment: "")
                )
            }
        }
        .sheet(isPresented: $showingReadingSettings) {
            ReadingSettingsView(showsReadingMode: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadIfNeeded()
            viewModel.refreshBookmarks()
        }
    }

    private func reader(_ layout: MushafLayout) -> some View {
        GeometryReader { screen in
            let isSpread = allowsSpread && Self.showsSpread(in: screen.size)
            let pages = isSpread
                ? layout.spreadPages(forPage: viewModel.currentPage)
                : [viewModel.currentPage]

            VStack(spacing: 0) {
                pageHeader(pages: pages)

                GeometryReader { geometry in
                    if isSpread {
                        spreadPager(layout, size: geometry.size)
                    } else {
                        pagePager(layout, size: geometry.size)
                    }
                }

                pageFooter(pages: pages)
                    .padding(.bottom, 72)
            }
        }
    }

    private func pagePager(_ layout: MushafLayout, size: CGSize) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(1...layout.pageCount, id: \.self) { page in
                    MushafPageView(
                        page: page,
                        maxPixelWidth: size.width * displayScale,
                        viewModel: viewModel
                    )
                    .frame(width: size.width, height: size.height)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $viewModel.scrolledPage)
        .scrollIndicators(.hidden)
        // Page 1 on the right, swiping left to read on.
        .environment(\.layoutDirection, .rightToLeft)
    }

    /// One spread per screen, the odd page on the right. The scroll position
    /// is the spread's first page, so folding back to one page keeps the
    /// place.
    private func spreadPager(_ layout: MushafLayout, size: CGSize) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(layout.spreadStarts, id: \.self) { start in
                    // Edge to edge with only a hairline spine, since a
                    // spread is as wide as the screen allows.
                    HStack(spacing: 0) {
                        ForEach(layout.spreadPages(forPage: start), id: \.self) { page in
                            MushafPageView(
                                page: page,
                                maxPixelWidth: size.width / 2 * displayScale,
                                horizontalPadding: 2,
                                viewModel: viewModel
                            )
                            .frame(width: size.width / 2, height: size.height)
                        }
                    }
                    .overlay {
                        Rectangle()
                            .fill(Color.textGray.opacity(0.15))
                            .frame(width: 1)
                            .padding(.vertical, 24)
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(
            id: Binding(
                get: { viewModel.scrolledPage.map(layout.spreadStart(forPage:)) },
                set: { viewModel.scrolledPage = $0 }
            )
        )
        .scrollIndicators(.hidden)
        .environment(\.layoutDirection, .rightToLeft)
    }

    /// The page number with a bookmark button for each page shown: one
    /// beside a single page, or one under each page of a spread, the right
    /// page's on the right.
    private func pageFooter(pages: [Int]) -> some View {
        HStack(spacing: 12) {
            if pages.count == 2 {
                bookmarkButton(page: pages[1])
                Spacer(minLength: 8)
            }

            Text(pageLabel(pages))
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
                .foregroundColor(.lightGreen)
                .accessibilityHidden(true)

            if pages.count == 2 {
                Spacer(minLength: 8)
            }

            if let page = pages.first {
                bookmarkButton(page: page)
            }
        }
        .padding(.horizontal, pages.count == 2 ? 24 : 0)
        .frame(height: 44)
    }

    private func bookmarkButton(page: Int) -> some View {
        let isBookmarked = viewModel.isBookmarked(page: page)

        return Button {
            viewModel.toggleBookmark(page: page)
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.lightGreen)
                .frame(width: 36, height: 36)
                .background(Color.backgroundGray)
                .clipShape(Circle())
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

    private func pageLabel(_ pages: [Int]) -> String {
        guard pages.count == 2 else {
            return String(
                format: NSLocalizedString("quran_mushaf_page_format", comment: ""),
                pages.first ?? viewModel.currentPage
            )
        }
        return String(
            format: NSLocalizedString("quran_mushaf_spread_format", comment: ""),
            pages[0],
            pages[1]
        )
    }

    private func pageHeader(pages: [Int]) -> some View {
        let surahs = pages
            .flatMap(viewModel.surahs(onPage:))
            .reduce(into: [Int]()) { result, surah in
                if !result.contains(surah) { result.append(surah) }
            }

        return HStack(spacing: 8) {
            Text(
                String(
                    format: NSLocalizedString("quran_mushaf_juz_format", comment: ""),
                    viewModel.juz(onPage: pages.first ?? viewModel.currentPage)
                )
            )
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.textGray)

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                ForEach(surahs, id: \.self) { surah in
                    if let ligature = Font.surahNameLigature(for: surah) {
                        Text(ligature)
                            .font(.surahNameFont(size: 30))
                            .foregroundColor(.lightGreen)
                    }
                }
            }
            // The first surah on the right, as Arabic reads.
            .environment(\.layoutDirection, .rightToLeft)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .frame(height: 36)
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.lightGreen)

            Text(NSLocalizedString("quran_mushaf_load_error", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(.title)
                .multilineTextAlignment(.center)

            Button(NSLocalizedString("quran_mushaf_retry", comment: "")) {
                viewModel.retry()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.lightGreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

/// One page, decoded at the screen's width and tinted with the text colour
/// so it reads in dark mode too.
struct MushafPageView: View {
    let page: Int
    let maxPixelWidth: CGFloat
    var horizontalPadding: CGFloat = 8
    let viewModel: MushafViewModel

    @State private var image: CGImage?

    var body: some View {
        ZStack {
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
                .padding(24)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, .leftToRight)
        .task(id: page) {
            image = await viewModel.image(forPage: page, maxPixelWidth: maxPixelWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.accessibilityLabel(forPage: page))
        .accessibilityAction(named: bookmarkActionName) {
            viewModel.toggleBookmark(page: page)
        }
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
