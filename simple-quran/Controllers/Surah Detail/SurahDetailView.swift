//
//  SurahDetailView.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/26/21.
//

import SwiftUI

struct SurahDetailView: View {
    let viewModel: SurahDetailViewModel

    @State private var activeSelection: DetailSelection?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.ayahs.isEmpty {
                        placeholder
                    } else {
                        detailCard

                        ForEach(viewModel.ayahs) { ayah in
                            ayahView(ayah)
                                .id(ayah.numberInSurah)
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
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }
    }

    private var detailCard: some View {
        VStack(spacing: 8) {
            Text(viewModel.surahName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.amiriRegular(size: 22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Rectangle()
                .fill(.white.opacity(0.85))
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            Text(viewModel.descriptionText)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Button {
                    activeSelection = .recitation
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.bubble")
                        Text(viewModel.reciterName)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                Button {
                    activeSelection = .translation
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text(viewModel.translationName)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.top, 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.lightGreen)
        )
        .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func ayahView(_ ayah: SurahDetailAyah) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.lightGreen)

                    Text("\(ayah.numberInSurah)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }

                Spacer()

                ShareLink(item: viewModel.shareText(for: ayah)) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .foregroundColor(.lightGreen)

                Button {
                    viewModel.toggleAudio(ayah: ayah)
                } label: {
                    Image(
                        systemName: viewModel.playingAyahID == ayah.id
                            ? "pause.fill"
                            : "play"
                    )
                    .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .foregroundColor(.lightGreen)

                Button {
                    viewModel.toggleBookmark(ayah: ayah)
                } label: {
                    Image(
                        systemName: viewModel.bookmarkedAyahs.contains(
                            ayah.numberInSurah
                        )
                            ? "bookmark.fill"
                            : "bookmark"
                    )
                    .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .foregroundColor(.lightGreen)
            }
            .padding(.horizontal, 16)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.backgroundGray)
            )
            .padding(.horizontal, 16)

            Text(ayah.arabic)
                .font(.kitabRegular(size: 22))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 16)

            Text(ayah.translation)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .multilineTextAlignment(
                    ayah.translationIsRTL ? .trailing : .leading
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: ayah.translationIsRTL ? .trailing : .leading
                )
                .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
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
