//
//  MushafNavigatorSheet.swift
//  simple-quran
//

import SwiftUI

/// Getting around the Mushaf: a filmstrip of pages, the thirty juz as a
/// progress bar, a surah list, a page number and the bookmarked pages.
/// Choosing anywhere moves the reader there and closes the sheet.
struct MushafNavigatorSheet: View {
    let viewModel: MushafViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var pageText = ""
    @State private var pageError: String?
    @FocusState private var pageFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    filmstrip
                    juzBar
                    shortcuts
                    bookmarks
                }
                .padding(.vertical, 16)
            }
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
            .navigationDestination(for: Destination.self) { _ in
                MushafSurahPicker(viewModel: viewModel) { surah in
                    go { viewModel.jump(toSurah: surah) }
                }
            }
        }
    }

    private enum Destination: Hashable {
        case surahs
    }

    private var currentPage: Int {
        viewModel.currentPage
    }

    private func go(_ move: () -> Void) {
        move()
        AppHaptics.tap()
        dismiss()
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(
                viewModel.surahs(onPage: currentPage)
                    .map(viewModel.surahName)
                    .joined(separator: " · ")
            )
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.title)

            Spacer(minLength: 8)

            Text(viewModel.juzAndHizbLabel(forPage: currentPage))
                .font(.system(size: 13))
                .foregroundColor(.textGray)
        }
        .padding(.horizontal, 16)
    }

    // MARK: Filmstrip

    private var filmstrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(1...max(viewModel.pageCount, 1), id: \.self) { page in
                        Button {
                            go { viewModel.jump(toPage: page) }
                        } label: {
                            MushafThumbnail(
                                page: page,
                                isCurrent: page == currentPage,
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
                proxy.scrollTo(currentPage, anchor: .center)
            }
        }
    }

    // MARK: Juz

    private var juzBar: some View {
        let current = viewModel.juz(onPage: currentPage)

        return VStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(1...viewModel.juzCount, id: \.self) { juz in
                    Button {
                        go { viewModel.jump(toJuz: juz) }
                    } label: {
                        Capsule()
                            .fill(juzColor(juz, current: current))
                            .frame(height: juz == current ? 10 : 6)
                            .frame(maxWidth: .infinity, minHeight: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        String(
                            format: NSLocalizedString("quran_mushaf_juz_format", comment: ""),
                            juz
                        )
                    )
                    .accessibilityAddTraits(juz == current ? .isSelected : [])
                }
            }
            .environment(\.layoutDirection, .rightToLeft)

            HStack {
                Text(
                    String(
                        format: NSLocalizedString("quran_mushaf_juz_format", comment: ""),
                        viewModel.juzCount
                    )
                )
                Spacer()
                Text(
                    String(
                        format: NSLocalizedString("quran_mushaf_juz_format", comment: ""),
                        1
                    )
                )
            }
            .font(.system(size: 11))
            .foregroundColor(.textGray)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
    }

    private func juzColor(_ juz: Int, current: Int) -> Color {
        if juz == current {
            return .lightGreen
        }
        if juz < current {
            return .lightGreen.opacity(0.35)
        }
        return .textGray.opacity(0.18)
    }

    // MARK: Surah and page

    private var shortcuts: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                NavigationLink(value: Destination.surahs) {
                    Label(
                        NSLocalizedString("quran_mushaf_choose_surah", comment: ""),
                        systemImage: "list.bullet"
                    )
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.backgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                HStack(spacing: 6) {
                    Image(systemName: "number")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textGray)

                    TextField(
                        NSLocalizedString("quran_mushaf_page_placeholder", comment: ""),
                        text: $pageText
                    )
                    .keyboardType(.numberPad)
                    .focused($pageFieldFocused)
                    .submitLabel(.go)
                    .onSubmit(goToTypedPage)
                    .onChange(of: pageText) { _, _ in
                        pageError = nil
                    }
                    .accessibilityLabel(NSLocalizedString("quran_mushaf_page_field", comment: ""))

                    Button(NSLocalizedString("quran_mushaf_go", comment: ""), action: goToTypedPage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            if let pageError {
                Text(pageError)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
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
        pageFieldFocused = false
        go { viewModel.jump(toPage: page) }
    }

    // MARK: Bookmarks

    @ViewBuilder
    private var bookmarks: some View {
        let pages = viewModel.sortedBookmarkedPages
        if !pages.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("quran_mushaf_bookmarks_title", comment: ""))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textGray)
                    .padding(.horizontal, 16)

                // The same rows as the Bookmarks screen. A plain stack:
                // there are only a few, and they sit below the sheet's
                // first detent.
                VStack(spacing: 0) {
                    ForEach(pages, id: \.self) { page in
                        let surah = viewModel.surahs(onPage: page).first ?? 1

                        Button {
                            go { viewModel.jump(toPage: page) }
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
            }
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
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.sheetBackground)
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(NSLocalizedString("quran_mushaf_surah_search", comment: ""))
        )
        .navigationTitle(NSLocalizedString("quran_mushaf_choose_surah", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
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
