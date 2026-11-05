//
//  MushafView.swift
//  simple-quran
//

import SwiftUI

/// The Quran as Mushaf pages, framed like a printed copy and swiped right
/// to left. On a wide screen, such as an unfolded iPhone Duo or an iPad in
/// landscape, it shows two pages side by side like an open book. Readers
/// can also scroll the pages one under another.
///
/// The page has the screen to itself: a floating bar replaces the
/// navigation and tab bars, and tapping the page hides it.
struct MushafView: View {
    /// A spread needs room for two readable pages: at least 600 points
    /// across (an unfolded iPhone Duo is about 700), on a screen not much
    /// taller than wide. A phone held upright keeps one page.
    nonisolated static func showsSpread(in size: CGSize) -> Bool {
        size.height > 0 && size.width >= 600 && size.width / size.height >= 0.6
    }

    /// Room kept free above the page for the floating bar, so the page
    /// doesn't resize when the bar hides.
    static let toolbarReserve: CGFloat = 60

    @Bindable var viewModel: MushafViewModel

    @Environment(\.displayScale) private var displayScale
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @State private var showingReadingSettings = false
    @State private var showingNavigator = false

    @AppStorage(
        Storage.StorageKey.mushafShowsSpread.rawValue,
        store: Storage.userDefaults
    ) private var allowsSpread = true

    @AppStorage(
        Storage.StorageKey.mushafScrollsVertically.rawValue,
        store: Storage.userDefaults
    ) private var scrollsVertically = false

    var body: some View {
        GeometryReader { screen in
            let isSpread = !scrollsVertically
                && allowsSpread
                && Self.showsSpread(in: screen.size)

            ZStack(alignment: .top) {
                content(isSpread: isSpread)
                    .padding(.top, Self.toolbarReserve)

                if !hidesChrome {
                    toolbar(isSpread: isSpread)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background(isSpread ? MushafSpreadView.canvas : Color.appBackground)
        }
        .navigationTitle(
            viewModel.surahs(onPage: viewModel.currentPage)
                .map(viewModel.surahName)
                .joined(separator: " · ")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .statusBarHidden(hidesChrome)
        .sheet(isPresented: $showingReadingSettings) {
            ReadingSettingsView(showsReadingMode: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingNavigator) {
            MushafNavigatorSheet(viewModel: viewModel)
                .presentationDetents([.height(340), .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadIfNeeded()
            viewModel.refreshBookmarks()
        }
    }

    /// VoiceOver users keep the bar: there is no page to tap.
    private var hidesChrome: Bool {
        viewModel.isChromeHidden && !voiceOverEnabled
    }

    @ViewBuilder
    private func content(isSpread: Bool) -> some View {
        if let layout = viewModel.layout {
            GeometryReader { geometry in
                if scrollsVertically {
                    verticalPager(layout, size: geometry.size)
                } else if isSpread {
                    spreadPager(layout, size: geometry.size)
                } else {
                    pagePager(layout, size: geometry.size)
                }
            }
        } else if viewModel.loadError != nil {
            errorState
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func pagePager(_ layout: MushafLayout, size: CGSize) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(1...layout.pageCount, id: \.self) { page in
                    MushafFramedPage(
                        page: page,
                        size: size,
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
                    MushafSpreadView(
                        pages: layout.spreadPages(forPage: start),
                        size: size,
                        displayScale: displayScale,
                        viewModel: viewModel
                    )
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

    /// Pages one under another, each as wide as the screen allows.
    private func verticalPager(_ layout: MushafLayout, size: CGSize) -> some View {
        let width = min(size.width, Self.maxScrollingPageWidth)
        let pageSize = CGSize(
            width: width,
            height: MushafPageMetrics.height(forWidth: width)
        )

        return ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(1...layout.pageCount, id: \.self) { page in
                    MushafFramedPage(
                        page: page,
                        size: pageSize,
                        maxPixelWidth: pageSize.width * displayScale,
                        viewModel: viewModel
                    )
                    .frame(width: size.width, height: pageSize.height)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $viewModel.scrolledPage, anchor: .top)
        .scrollIndicators(.automatic)
    }

    /// Wider pages than this are taller than any screen; on an iPad the
    /// page stays a readable size and centres.
    static let maxScrollingPageWidth: CGFloat = 620

    private func toolbar(isSpread: Bool) -> some View {
        let pages = isSpread
            ? (viewModel.layout?.spreadPages(forPage: viewModel.currentPage) ?? [viewModel.currentPage])
            : [viewModel.currentPage]

        return MushafToolbar(
            pageLabel: pageLabel(pages),
            detailLabel: viewModel.juzAndHizbLabel(forPage: pages.first ?? viewModel.currentPage),
            onBack: { dismiss() },
            onOpenNavigator: { showingNavigator = true },
            onOpenSettings: { showingReadingSettings = true }
        )
    }

    private func pageLabel(_ pages: [Int]) -> String {
        guard pages.count == 2 else {
            return String(
                format: NSLocalizedString("quran_mushaf_page_of_format", comment: ""),
                pages.first ?? viewModel.currentPage,
                viewModel.pageCount
            )
        }
        return String(
            format: NSLocalizedString("quran_mushaf_spread_format", comment: ""),
            pages[0],
            pages[1]
        )
    }

    private var errorState: some View {
        VStack(spacing: 16) {
            ZStack {
                MushafStarShape()
                    .stroke(Color.lightGreen, lineWidth: 1.5)
                    .frame(width: 64, height: 64)

                Image(systemName: "book.closed")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.lightGreen)
            }
            .accessibilityHidden(true)

            Text(NSLocalizedString("quran_mushaf_load_error", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(.title)
                .multilineTextAlignment(.center)

            AppPrimaryButton(
                title: NSLocalizedString("quran_mushaf_retry", comment: ""),
                icon: "arrow.clockwise",
                isEnabled: true
            ) {
                viewModel.retry()
            }
            .frame(maxWidth: 220)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

