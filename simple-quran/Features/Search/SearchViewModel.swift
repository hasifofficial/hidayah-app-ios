//
//  SearchViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

struct SearchBookmark: Identifiable {
    let surah: SurahListResponse
    let bookmark: SurahBookmark

    var id: String {
        "\(surah.number ?? 0)-\(bookmark.numberInSurah)"
    }
}

@Observable
final class SearchViewModel {
    var keyword: String = ""
    var isLoading = false
    var surahList: [SurahListResponse] = []
    var filteredSurahList: [SurahListResponse] = []
    var bookmarkedSurahs: [SearchBookmark] = []
    var filteredBookmarkedSurahs: [SearchBookmark] = []

    @ObservationIgnored
    var onSelectSurah: ((SurahListResponse) -> Void)?

    @ObservationIgnored
    var onSelectBookmark: ((SearchBookmark) -> Void)?

    @ObservationIgnored
    var onError: ((String) -> Void)?

    @ObservationIgnored
    private let surahService: SurahService

    @ObservationIgnored
    private var hasLoaded = false

    init(surahService: SurahService) {
        self.surahService = surahService
    }

    func loadIfNeeded() {
        if hasLoaded {
            refreshBookmarks()
            return
        }

        if SurahCatalog.shared.isLoaded,
           !SurahCatalog.shared.surahs.isEmpty {
            surahList = SurahCatalog.shared.surahs
            hasLoaded = true
            refreshBookmarks()
            return
        }

        load()
    }

    func load() {
        guard !isLoading else { return }

        isLoading = true

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let list = try await self.surahService.getSurahList()
                self.isLoading = false

                let surahs = list.data ?? []
                self.surahList = surahs
                SurahCatalog.shared.store(surahs)
                self.hasLoaded = true
                self.refreshBookmarks()
            } catch {
                self.isLoading = false
                self.onError?(
                    (error as? RequestError)?.message
                        ?? error.localizedDescription
                )
            }
        }
    }

    func refreshBookmarks() {
        guard !surahList.isEmpty else {
            bookmarkedSurahs = []
            applyFilter()
            return
        }

        let bookmarks = HidayahStore.shared.bookmarks()

        bookmarkedSurahs = bookmarks
            .sorted {
                if $0.surahNumber == $1.surahNumber {
                    return $0.numberInSurah < $1.numberInSurah
                }
                return $0.surahNumber < $1.surahNumber
            }
            .compactMap { bookmark in
                guard let surah = surahList.first(where: {
                    $0.number == bookmark.surahNumber
                }) else {
                    return nil
                }

                return SearchBookmark(
                    surah: surah,
                    bookmark: bookmark
                )
            }

        applyFilter()
    }

    func updateKeyword(_ keyword: String) {
        self.keyword = keyword
        applyFilter()
    }

    private func applyFilter() {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            filteredSurahList = []
            filteredBookmarkedSurahs = []
            return
        }

        let lowercasedQuery = query.lowercased()

        filteredSurahList = surahList.filter {
            $0.englishName?.lowercased().contains(lowercasedQuery) ?? false
        }
        filteredBookmarkedSurahs = bookmarkedSurahs.filter {
            $0.surah.englishName?.lowercased().contains(lowercasedQuery) ?? false
        }
    }
}
