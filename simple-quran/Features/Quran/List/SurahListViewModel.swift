//
//  SurahListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SurahListViewModel {
    private(set) var surahs: [SurahListResponse] = []
    private(set) var isLoading = true

    @ObservationIgnored
    var onSelect: ((SurahListResponse) -> Void)?

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
        guard !hasLoaded else { return }

        hasLoaded = true

        if SurahCatalog.shared.isLoaded,
           !SurahCatalog.shared.surahs.isEmpty {
            surahs = SurahCatalog.shared.surahs
            isLoading = false
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
            self.surahs = surahs
            SurahCatalog.shared.store(surahs)
        } catch {
            isLoading = false

            if SurahCatalog.shared.isLoaded {
                surahs = SurahCatalog.shared.surahs
            } else {
                surahs = []
            }
            onError?(
                (error as? RequestError)?.message
                    ?? error.localizedDescription
            )
        }
    }

    func refresh() async {
        await load()
    }
}
