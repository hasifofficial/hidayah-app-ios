//
//  BookmarkListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

struct BookmarkedSurah: Identifiable {
    let surah: SurahListResponse
    let bookmark: SurahBookmark

    var id: String {
        "\(bookmark.surahNumber)-\(bookmark.numberInSurah)"
    }
}

@Observable
final class BookmarkListViewModel {
    private(set) var bookmarks: [BookmarkedSurah] = []
    private(set) var isLoading = true

    @ObservationIgnored
    var onSelect: ((BookmarkedSurah) -> Void)?

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
            hydrate(with: SurahCatalog.shared.surahs)
            return
        }

        hasLoaded = true

        if SurahCatalog.shared.isLoaded,
           !SurahCatalog.shared.surahs.isEmpty {
            isLoading = false
            hydrate(with: SurahCatalog.shared.surahs)
            return
        }

        Task { [weak self] in
            await self?.load()
        }
    }

    @MainActor
    func load() async {
        isLoading = true

        do {
            let list = try await surahService.getSurahList()
            isLoading = false

            let surahs = list.data ?? []
            SurahCatalog.shared.store(surahs)
            hydrate(with: surahs)
        } catch {
            isLoading = false
            bookmarks = []
            onError?(
                (error as? RequestError)?.message
                    ?? error.localizedDescription
            )
        }
    }

    private func hydrate(with surahs: [SurahListResponse]) {
        guard !surahs.isEmpty else {
            bookmarks = []
            return
        }

        let storedBookmarks = HidayahStore.shared.bookmarks()
        let sortedBookmarks = storedBookmarks.sorted {
            if $0.surahNumber == $1.surahNumber {
                return $0.numberInSurah < $1.numberInSurah
            }
            return $0.surahNumber < $1.surahNumber
        }

        bookmarks = sortedBookmarks.compactMap { bookmark in
            guard let surah = surahs.first(where: {
                $0.number == bookmark.surahNumber
            }) else {
                return nil
            }

            return BookmarkedSurah(
                surah: surah,
                bookmark: bookmark
            )
        }
    }

    func refresh() async {
        await load()
    }
}
