//
//  BookmarkListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Combine
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
    private var cancellables = Set<AnyCancellable>()

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

        load()
    }

    func load(completion: (() -> Void)? = nil) {
        isLoading = true

        surahService.getSurahList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                defer { completion?() }
                guard let self else { return }

                self.isLoading = false

                if case .failure(let error) = result {
                    self.bookmarks = []
                    self.onError?(
                        (error as? RequestError)?.message
                            ?? error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] list in
                guard let self else { return }

                let surahs = list.data ?? []
                SurahCatalog.shared.store(surahs)
                self.hydrate(with: surahs)
            }
            .store(in: &cancellables)
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
        await withCheckedContinuation { continuation in
            load {
                continuation.resume()
            }
        }
    }
}
