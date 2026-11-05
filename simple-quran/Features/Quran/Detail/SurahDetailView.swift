//
//  SurahDetailView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import SwiftUI

struct SurahDetailView: View {
    let viewModel: SurahDetailViewModel

    @State private var activeSelection: DetailSelection?
    @State private var showingReadingSettings = false

    @AppStorage(
        Storage.StorageKey.quranArabicFontSize.rawValue,
        store: Storage.userDefaults
    ) private var arabicFontSize = 22.0

    @AppStorage(
        Storage.StorageKey.quranShowTranslation.rawValue,
        store: Storage.userDefaults
    ) private var showTranslation = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.ayahs.isEmpty {
                        placeholder
                    } else {
                        detailCard
                            .loadAnimation(offset: 16)

                        ForEach(
                            Array(viewModel.ayahs.enumerated()),
                            id: \.element.id
                        ) { index, ayah in
                            ayahView(ayah)
                                .id(ayah.numberInSurah)
                                .loadAnimation(
                                    delay: min(
                                        Double(index) * 0.02,
                                        0.3
                                    ),
                                    offset: 12
                                )
                        }
                    }
                }
            }
            .background(.appBackground)
            .onChange(of: viewModel.scrollToAyah) { _, ayah in
                guard let ayah else { return }

                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo(ayah, anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
        .sheet(item: $activeSelection) { selection in
            SelectionView(
                title: selection.title,
                items: selection == .recitation
                    ? viewModel.recitationItems
                    : viewModel.translationItems,
                selectedValue: selection == .recitation
                    ? viewModel.selectedRecitationValue
                    : viewModel.selectedTranslationValue,
                onSelect: { item in
                    switch selection {
                    case .recitation:
                        viewModel.selectRecitation(item)
                    case .translation:
                        viewModel.selectTranslation(item)
                    }
                }
            )
        }
        .navigationTitle(viewModel.title)
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
                    NSLocalizedString(
                        "quran_reading_settings_title",
                        comment: ""
                    )
                )
            }
        }
        .sheet(isPresented: $showingReadingSettings) {
            ReadingSettingsView(showsReadingMode: true)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button(NSLocalizedString("common_ok", comment: "")) {
                viewModel.errorMessage = nil
            }
        }
    }

    private var detailCard: some View {
        ReaderHeaderCard(
            icon: "book.closed.fill",
            label: NSLocalizedString("surah_detail_heading", comment: ""),
            title: viewModel.surahName
        ) {
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.amiriRegular(size: 23))
                .foregroundColor(.lightGreen)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.descriptionText)
                .font(.system(size: 13))
                .foregroundColor(.textGray)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ReaderSelectionButton(
                    icon: "speaker.wave.2.bubble",
                    title: viewModel.reciterName
                ) {
                    activeSelection = .recitation
                }

                ReaderSelectionButton(
                    icon: "globe",
                    title: viewModel.translationName
                ) {
                    activeSelection = .translation
                }
            }
        }
    }

    private func ayahView(_ ayah: SurahDetailAyah) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                NumberSealBadge(number: ayah.numberInSurah)

                Spacer(minLength: 8)

                ShareLink(item: viewModel.shareText(for: ayah)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lightGreen)
                        .frame(width: 40, height: 40)
                        .background(Color.backgroundGray)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    NSLocalizedString("surah_detail_share_ayah", comment: "")
                )

                ReaderCircleButton(
                    icon: viewModel.playingAyahID == ayah.id
                        ? "pause.fill"
                        : "play.fill",
                    isActive: viewModel.playingAyahID == ayah.id,
                    accessibilityLabel: NSLocalizedString(
                        viewModel.playingAyahID == ayah.id
                            ? "surah_detail_pause_ayah"
                            : "surah_detail_play_ayah",
                        comment: ""
                    )
                ) {
                    viewModel.toggleAudio(ayah: ayah)
                }

                ReaderCircleButton(
                    icon: viewModel.bookmarkedAyahs.contains(
                        ayah.numberInSurah
                    )
                        ? "bookmark.fill"
                        : "bookmark",
                    isActive: viewModel.bookmarkedAyahs.contains(
                        ayah.numberInSurah
                    ),
                    accessibilityLabel: NSLocalizedString(
                        viewModel.bookmarkedAyahs.contains(
                            ayah.numberInSurah
                        )
                            ? "surah_detail_remove_bookmark_ayah"
                            : "surah_detail_bookmark_ayah",
                        comment: ""
                    )
                ) {
                    viewModel.toggleBookmark(ayah: ayah)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ReaderTextBlock(
                arabic: ayah.arabic,
                translation: showTranslation ? ayah.translation : nil,
                translationIsRTL: ayah.translationIsRTL,
                arabicFontSize: arabicFontSize
            )

            ReaderRowDivider()
        }
        .padding(.top, 8)
    }

    private var placeholder: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.lightGreen.opacity(0.25))
                .frame(height: 220)

            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.backgroundGray)
                        .frame(height: 46)

                    ShimmerBar()
                        .frame(height: 16)

                    ShimmerBar()
                        .frame(width: 200, height: 12)
                }
            }
        }
        .padding(16)
    }
}

private enum DetailSelection: String, Identifiable {
    case recitation
    case translation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recitation:
            return NSLocalizedString(
                "surah_recitation_drawer_title",
                comment: ""
            )
        case .translation:
            return NSLocalizedString(
                "surah_translation_drawer_title",
                comment: ""
            )
        }
    }
}

/// Every way into a surah lands here; it shows the ayah list or the Mushaf
/// pages, following the reading mode.
struct SurahDetailScreen: View {
    @State private var viewModel: SurahDetailViewModel
    @State private var mushafViewModel: MushafViewModel

    @AppStorage(
        Storage.StorageKey.quranReadingMode.rawValue,
        store: Storage.userDefaults
    ) private var readingMode = QuranReadingMode.list

    init(
        surahService: SurahService,
        surahNumber: Int,
        title: String?,
        bookmarkedAyah: Int?,
        mushafLoader: MushafLoading = BundleMushafLoader()
    ) {
        let viewModel = SurahDetailViewModel(
            surahService: surahService,
            bookmarkedAyah: bookmarkedAyah,
            scrollToSpecificAyah: bookmarkedAyah != nil
        )
        viewModel.selectedSurahNo = surahNumber
        viewModel.title = title ?? ""
        _viewModel = State(initialValue: viewModel)
        _mushafViewModel = State(
            initialValue: MushafViewModel(
                surahNumber: surahNumber,
                ayahNumber: bookmarkedAyah,
                loader: mushafLoader
            )
        )
    }

    var body: some View {
        switch readingMode {
        case .list:
            SurahDetailView(viewModel: viewModel)
        case .mushaf:
            MushafView(viewModel: mushafViewModel)
        }
    }
}
