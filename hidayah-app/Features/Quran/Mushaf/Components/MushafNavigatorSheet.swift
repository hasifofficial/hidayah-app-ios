//
//  MushafNavigatorSheet.swift
//  simple-quran
//

import SwiftUI

/// Getting around the Mushaf. A card says where the reader is; tabs below
/// it offer the surahs, the thirty juz, a page number with a filmstrip,
/// and the bookmarked pages. Choosing anywhere moves the reader there and
/// closes the sheet.
struct MushafNavigatorSheet: View {
    let viewModel: MushafViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab = .surah

    enum Tab: CaseIterable, Identifiable {
        case surah, juz, page, bookmarks

        var id: Self { self }

        var titleKey: String {
            switch self {
            case .surah: "quran_mushaf_tab_surah"
            case .juz: "quran_mushaf_tab_juz"
            case .page: "quran_mushaf_tab_page"
            case .bookmarks: "quran_mushaf_tab_bookmarks"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                MushafLocationCard(viewModel: viewModel)
                    .padding(.horizontal, 16)

                tabPicker
                    .padding(.horizontal, 16)

                Group {
                    switch tab {
                    case .surah:
                        MushafSurahPicker(viewModel: viewModel) { surah in
                            go { viewModel.jump(toSurah: surah) }
                        }
                    case .juz:
                        MushafJuzGrid(viewModel: viewModel) { juz in
                            go { viewModel.jump(toJuz: juz) }
                        }
                    case .page:
                        MushafPagePanel(viewModel: viewModel) { page in
                            go { viewModel.jump(toPage: page) }
                        }
                    case .bookmarks:
                        MushafBookmarkedPages(viewModel: viewModel) { page in
                            go { viewModel.jump(toPage: page) }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(.top, 4)
            .background(Color.sheetBackground)
            .navigationTitle(NSLocalizedString("quran_mushaf_navigator_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("quran_reading_done", comment: "")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.lightGreen)
                }
            }
        }
    }

    private func go(_ move: () -> Void) {
        move()
        AppHaptics.tap()
        dismiss()
    }

    /// The system segmented control, so it takes the platform look:
    /// Liquid Glass on iOS 26.
    private var tabPicker: some View {
        Picker(
            NSLocalizedString("quran_mushaf_navigator_title", comment: ""),
            selection: $tab.animation(.easeInOut(duration: 0.2))
        ) {
            ForEach(Tab.allCases) { item in
                Text(NSLocalizedString(item.titleKey, comment: ""))
                    .tag(item)
            }
        }
        .pickerStyle(.segmented)
    }
}

/// Where the reader is: the surah, juz, hizb and page, and how far through
/// the Mushaf that is.
struct MushafLocationCard: View {
    let viewModel: MushafViewModel

    private var page: Int { viewModel.currentPage }

    /// The last surah on the page: where one ends and the next begins,
    /// the one that starts here.
    private var surah: Int {
        viewModel.surahs(onPage: page).last ?? 1
    }

    private var progress: Double {
        guard viewModel.pageCount > 1 else { return 0 }
        return Double(page - 1) / Double(viewModel.pageCount - 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("quran_mushaf_reading_now", comment: ""))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.lightGreen)
                .textCase(.uppercase)

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        viewModel.surahs(onPage: page)
                            .map(viewModel.surahName)
                            .joined(separator: " · ")
                    )
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    Text(
                        "\(viewModel.juzAndHizbLabel(forPage: page)) · "
                            + String(
                                format: NSLocalizedString("quran_mushaf_page_of_format", comment: ""),
                                page,
                                viewModel.pageCount
                            )
                    )
                    .font(.system(size: 12))
                    .foregroundColor(.textGray)
                    .monospacedDigit()
                }

                Spacer(minLength: 4)

                if let ligature = Font.surahNameLigature(for: surah) {
                    Text(ligature)
                        .font(.surahNameFont(size: 44))
                        .foregroundColor(.lightGreen)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.lightGreen.opacity(0.18))
                    Capsule()
                        .fill(Color.lightGreen)
                        .frame(width: max(4, proxy.size.width * progress))
                }
            }
            .frame(height: 4)
            .accessibilityHidden(true)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.lightGreen.opacity(0.14), Color.backgroundGray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The thirty juz as a grid of tiles, each with the page it starts on.
struct MushafJuzGrid: View {
    let viewModel: MushafViewModel
    let onSelect: (Int) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 5
    )

    var body: some View {
        let current = viewModel.juz(onPage: viewModel.currentPage)

        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...max(viewModel.juzCount, 1), id: \.self) { juz in
                    let isCurrent = juz == current

                    Button {
                        onSelect(juz)
                    } label: {
                        VStack(spacing: 2) {
                            Text("\(juz)")
                                .font(.system(size: 17, weight: .bold))
                                .monospacedDigit()
                            Text(
                                String(
                                    format: NSLocalizedString("quran_mushaf_page_short_format", comment: ""),
                                    viewModel.startPage(ofJuz: juz)
                                )
                            )
                            .font(.system(size: 10))
                            .monospacedDigit()
                            .opacity(0.75)
                        }
                        .foregroundColor(isCurrent ? .white : .title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isCurrent ? Color.lightGreen : Color.backgroundGray)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        String(format: NSLocalizedString("quran_mushaf_juz_format", comment: ""), juz)
                    )
                    .accessibilityValue(
                        String(
                            format: NSLocalizedString("quran_mushaf_page_format", comment: ""),
                            viewModel.startPage(ofJuz: juz)
                        )
                    )
                    .accessibilityAddTraits(isCurrent ? .isSelected : [])
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

/// A page number to type, above a filmstrip of every page.
struct MushafPagePanel: View {
    let viewModel: MushafViewModel
    let onSelect: (Int) -> Void

    @State private var pageText = ""
    @State private var pageError: String?
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "number")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.lightGreen)

                        TextField(
                            String(
                                format: NSLocalizedString("quran_mushaf_page_range_placeholder", comment: ""),
                                viewModel.pageCount
                            ),
                            text: $pageText
                        )
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .focused($fieldFocused)
                        .submitLabel(.go)
                        .onSubmit(goToTypedPage)
                        .onChange(of: pageText) { _, _ in
                            pageError = nil
                        }
                        .accessibilityLabel(NSLocalizedString("quran_mushaf_page_field", comment: ""))

                        Button(action: goToTypedPage) {
                            Text(NSLocalizedString("quran_mushaf_go", comment: ""))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .frame(height: 34)
                                .background(Color.lightGreen)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.leading, 14)
                    .padding(.trailing, 6)
                    .frame(height: 48)
                    .background(Color.backgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    if let pageError {
                        Text(pageError)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("quran_mushaf_nearby_pages", comment: ""))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textGray)
                        .textCase(.uppercase)
                        .padding(.horizontal, 16)

                    filmstrip
                }
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var filmstrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(1...max(viewModel.pageCount, 1), id: \.self) { page in
                        Button {
                            onSelect(page)
                        } label: {
                            MushafThumbnail(
                                page: page,
                                isCurrent: page == viewModel.currentPage,
                                isBookmarked: viewModel.isBookmarked(page: page),
                                viewModel: viewModel
                            )
                        }
                        .buttonStyle(.plain)
                        .id(page)
                        .accessibilityLabel(
                            String(
                                format: NSLocalizedString("quran_mushaf_go_to_page_format", comment: ""),
                                page
                            )
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .frame(height: MushafThumbnail.height)
            // Page 1 on the right, as the reader pages.
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                proxy.scrollTo(viewModel.currentPage, anchor: .center)
            }
        }
    }

    private func goToTypedPage() {
        let digits = pageText.trimmingCharacters(in: .whitespaces)
        guard let page = Int(digits), (1...viewModel.pageCount).contains(page) else {
            pageError = String(
                format: NSLocalizedString("quran_mushaf_page_error_format", comment: ""),
                viewModel.pageCount
            )
            return
        }
        fieldFocused = false
        onSelect(page)
    }
}

/// The bookmarked pages, in the same rows as the Bookmarks screen.
struct MushafBookmarkedPages: View {
    let viewModel: MushafViewModel
    let onSelect: (Int) -> Void

    var body: some View {
        let pages = viewModel.sortedBookmarkedPages

        if pages.isEmpty {
            // In a scroll view it gets its full height, so it keeps the
            // icon it drops when the sheet is at half height.
            ScrollView {
                emptyState
            }
        } else {
            bookmarkList(pages)
        }
    }

    /// The same empty state as the Bookmarks screen.
    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(NSLocalizedString("bookmark_list_empty_list_title", comment: ""))
            } icon: {
                Image(systemName: "bookmark")
            }
        } description: {
            Text(NSLocalizedString("bookmark_list_empty_list_subtitle", comment: ""))
        }
    }

    private func bookmarkList(_ pages: [Int]) -> some View {
        ScrollView {
            // A plain stack: there are only a few.
            VStack(spacing: 0) {
                ForEach(pages, id: \.self) { page in
                    let surah = viewModel.surahs(onPage: page).first ?? 1

                    Button {
                        onSelect(page)
                    } label: {
                        SurahListRowView(
                            title: viewModel.surahName(surah),
                            subtitle: String(
                                format: NSLocalizedString("quran_mushaf_page_format", comment: ""),
                                page
                            ),
                            arabicTitle: viewModel.surahArabicName(surah),
                            surahNumber: surah,
                            badgeIcon: "bookmark.fill"
                        )
                        .accessibilityElement(children: .combine)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 16)
        }
    }
}

/// A small page in the navigator's filmstrip.
struct MushafThumbnail: View {
    static let height: CGFloat = 104

    let page: Int
    let isCurrent: Bool
    let isBookmarked: Bool
    let viewModel: MushafViewModel

    @State private var image: CGImage?

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.appBackground)

                if let image {
                    Image(decorative: image, scale: 1)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.primary)
                        .padding(3)
                }

                if isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 9))
                        .foregroundColor(MushafBookmarkRibbon.color)
                        .padding(.top, 1)
                }
            }
            .frame(width: 52, height: 52 / MushafPageMetrics.pageAspect)
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(
                        isCurrent ? Color.lightGreen : Color.textGray.opacity(0.2),
                        lineWidth: isCurrent ? 2 : 0.5
                    )
            }

            Text("\(page)")
                .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                .monospacedDigit()
                .foregroundColor(isCurrent ? .lightGreen : .textGray)
        }
        .environment(\.layoutDirection, .leftToRight)
        .task(id: page) {
            image = await viewModel.thumbnail(forPage: page)
        }
    }
}

/// Every surah with its first page, searchable by name or number, in the
/// same rows as the Quran tab's surah list.
struct MushafSurahPicker: View {
    let viewModel: MushafViewModel
    let onSelect: (Int) -> Void

    @State private var query = ""

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textGray)

                TextField(
                    NSLocalizedString("quran_mushaf_surah_search", comment: ""),
                    text: $query
                )
                .font(.system(size: 15))
                .autocorrectionDisabled()

                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textGray)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("quran_mushaf_clear_search", comment: ""))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredSurahs, id: \.self) { surah in
                            Button {
                                onSelect(surah)
                            } label: {
                                SurahListRowView(
                                    title: viewModel.surahName(surah),
                                    subtitle: viewModel.surahStartPageLabel(surah),
                                    arabicTitle: viewModel.surahArabicName(surah),
                                    surahNumber: surah,
                                    badgeText: String(surah)
                                )
                                // One element for VoiceOver, as in the surah list.
                                .accessibilityElement(children: .combine)
                            }
                            .buttonStyle(.plain)
                            .id(surah)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    // Start at the surah being read.
                    let current = viewModel.surahs(onPage: viewModel.currentPage).first ?? 1
                    proxy.scrollTo(current, anchor: .top)
                }
            }
        }
    }

    private var filteredSurahs: [Int] {
        let all = Array(1...MushafLayout.surahCount)
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        if let number = Int(trimmed) {
            return all.filter { $0 == number }
        }
        return all.filter {
            viewModel.surahName($0).localizedCaseInsensitiveContains(trimmed)
        }
    }
}
