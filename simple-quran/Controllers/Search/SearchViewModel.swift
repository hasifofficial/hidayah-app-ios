//
//  SearchViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/1/25.
//

import Foundation
import Combine
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
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var hasLoaded = false

    init(surahService: SurahService) {
        self.surahService = surahService
    }

    func loadIfNeeded() {
        if hasLoaded {
            refreshBookmarks()
        } else {
            load()
        }
    }

    func load() {
        guard !isLoading else { return }

        isLoading = true

        surahService.getSurahList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }

                self.isLoading = false

                if case .failure(let error) = completion {
                    self.onError?(
                        (error as? RequestError)?.message
                            ?? error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] list in
                guard let self else { return }

                self.surahList = list.data ?? []
                self.hasLoaded = true
                self.refreshBookmarks()
            }
            .store(in: &cancellables)
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
