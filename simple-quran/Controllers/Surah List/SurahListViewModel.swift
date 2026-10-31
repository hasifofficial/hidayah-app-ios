//
//  SurahListViewModel.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Foundation
import Combine
import Observation

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
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    private var hasLoaded = false

    init(surahService: SurahService) {
        self.surahService = surahService
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }

        hasLoaded = true
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
                    self.surahs = []
                    self.onError?(
                        (error as? RequestError)?.message
                            ?? error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] list in
                self?.surahs = list.data ?? []
            }
            .store(in: &cancellables)
    }

    func refresh() async {
        await withCheckedContinuation { continuation in
            load {
                continuation.resume()
            }
        }
    }
}
