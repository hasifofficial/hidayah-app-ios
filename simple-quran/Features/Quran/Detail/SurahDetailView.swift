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
            QuranReadingSettingsView()
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
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.lightGreen.opacity(0.12))

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.lightGreen)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(NSLocalizedString("surah_detail_heading", comment: ""))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.textGray)
                        .textCase(.uppercase)

                    Text(viewModel.surahName)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(.title)
                }

                Spacer(minLength: 0)
            }

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
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
                selectionButton(
                    icon: "speaker.wave.2.bubble",
                    title: viewModel.reciterName
                ) {
                    activeSelection = .recitation
                }

                selectionButton(
                    icon: "globe",
                    title: viewModel.translationName
                ) {
                    activeSelection = .translation
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.lightGreen.opacity(0.14),
                            Color.backgroundGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.lightGreen.opacity(0.16), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func selectionButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lightGreen)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.title)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func ayahView(_ ayah: SurahDetailAyah) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.lightGreen)

                    Text("\(ayah.numberInSurah)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }

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

                ayahActionButton(
                    icon: viewModel.playingAyahID == ayah.id
                        ? "pause.fill"
                        : "play.fill",
                    isActive: viewModel.playingAyahID == ayah.id,
                    accessibilityLabel: viewModel.playingAyahID == ayah.id
                        ? "surah_detail_pause_ayah"
                        : "surah_detail_play_ayah"
                ) {
                    viewModel.toggleAudio(ayah: ayah)
                }

                ayahActionButton(
                    icon: viewModel.bookmarkedAyahs.contains(
                        ayah.numberInSurah
                    )
                        ? "bookmark.fill"
                        : "bookmark",
                    isActive: viewModel.bookmarkedAyahs.contains(
                        ayah.numberInSurah
                    ),
                    accessibilityLabel: viewModel.bookmarkedAyahs.contains(
                        ayah.numberInSurah
                    )
                        ? "surah_detail_remove_bookmark_ayah"
                        : "surah_detail_bookmark_ayah"
                ) {
                    viewModel.toggleBookmark(ayah: ayah)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text(ayah.arabic)
                .font(.kitabRegular(size: CGFloat(arabicFontSize)))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineSpacing(6)
                .padding(.horizontal, 16)
                .padding(.top, 10)

            if showTranslation {
                Text(ayah.translation)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .multilineTextAlignment(
                        ayah.translationIsRTL ? .trailing : .leading
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: ayah.translationIsRTL ? .trailing : .leading
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }

            Divider()
                .overlay(Color.textGray.opacity(0.12))
                .padding(.horizontal, 16)
                .padding(.top, 18)
        }
        .padding(.top, 8)
    }

    private func ayahActionButton(
        icon: String,
        isActive: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isActive ? .white : .lightGreen)
                .frame(width: 40, height: 40)
                .background(isActive ? Color.lightGreen : Color.backgroundGray)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString(accessibilityLabel, comment: ""))
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

struct SurahDetailScreen: View {
    @State private var viewModel: SurahDetailViewModel

    init(
        surahService: SurahService,
        surahNumber: Int,
        title: String?,
        bookmarkedAyah: Int?
    ) {
        let viewModel = SurahDetailViewModel(
            surahService: surahService,
            bookmarkedAyah: bookmarkedAyah,
            scrollToSpecificAyah: bookmarkedAyah != nil
        )
        viewModel.selectedSurahNo = surahNumber
        viewModel.title = title ?? ""
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        SurahDetailView(viewModel: viewModel)
    }
}
