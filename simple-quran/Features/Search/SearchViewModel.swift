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

@MainActor
@Observable
final class SearchViewModel {
    var keyword: String = ""
    var isLoading = false
    var surahList: [SurahListResponse] = []
    var filteredSurahList: [SurahListResponse] = []
    var bookmarkedSurahs: [SearchBookmark] = []
    var filteredBookmarkedSurahs: [SearchBookmark] = []
    /// Matching entries of the Al-Mathurat session for the current time of
    /// day, the one the Mathurat tab shows.
    var filteredMathurat: [MathuratEntry] = []

    @ObservationIgnored
    var onSelectSurah: ((SurahListResponse) -> Void)?

    @ObservationIgnored
    var onSelectBookmark: ((SearchBookmark) -> Void)?

    @ObservationIgnored
    var onSelectMathurat: ((MathuratEntry) -> Void)?

    @ObservationIgnored
    var onError: ((String) -> Void)?

    @ObservationIgnored
    private let surahService: SurahService

    @ObservationIgnored
    private let catalog: SurahCatalog

    @ObservationIgnored
    private let store: HidayahStore

    @ObservationIgnored
    private let mathuratLoader: MathuratLoading

    @ObservationIgnored
    private let now: () -> Date

    @ObservationIgnored
    private let calendar: Calendar

    @ObservationIgnored
    private var mathuratEntries: [MathuratTime: [MathuratEntry]] = [:]

    @ObservationIgnored
    private var hasLoaded = false

    init(
        surahService: SurahService,
        catalog: SurahCatalog = .shared,
        store: HidayahStore = .shared,
        mathuratLoader: MathuratLoading = BundleMathuratLoader(),
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.surahService = surahService
        self.catalog = catalog
        self.store = store
        self.mathuratLoader = mathuratLoader
        self.now = now
        self.calendar = calendar
    }

    func loadIfNeeded() {
        if hasLoaded {
            refreshBookmarks()
            return
        }

        if catalog.isLoaded,
           !catalog.surahs.isEmpty {
            surahList = catalog.surahs
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
                catalog.store(surahs)
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

        let bookmarks = store.bookmarks()

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
            filteredMathurat = []
            return
        }

        let lowercasedQuery = query.lowercased()

        filteredSurahList = surahList.filter {
            $0.englishName?.lowercased().contains(lowercasedQuery) ?? false
        }
        filteredBookmarkedSurahs = bookmarkedSurahs.filter {
            $0.surah.englishName?.lowercased().contains(lowercasedQuery) ?? false
        }
        filteredMathurat = currentMathuratEntries().filter {
            $0.title?.localizedStandardContains(query) ?? false
        }
    }

    /// The bundled entries for the current time of day. A load failure is
    /// logged by the loader and just leaves the section empty.
    private func currentMathuratEntries() -> [MathuratEntry] {
        let time = MathuratTime.current(at: now(), calendar: calendar)
        if let entries = mathuratEntries[time] {
            return entries
        }

        let entries = (try? mathuratLoader.entries(for: time)) ?? []
        mathuratEntries[time] = entries
        return entries
    }
}
