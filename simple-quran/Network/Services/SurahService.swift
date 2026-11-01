//
//  SurahService.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/06/2023.
//

import Foundation
import Combine

protocol SurahServiceable {
    func getSurahEdition() -> Future<Edition, Error>
    func getSurahList() -> Future<SurahList, Error>
    func getSurahDetail(surahNo: Int, recitationId: String, translationId: String) -> Future<Surah, Error>
}

class SurahService: SurahServiceable {
    private let apiClientService: APIClientService

    init(
        apiClientService: APIClientService
    ) {
        self.apiClientService = apiClientService
    }

    func getSurahEdition() -> Future<Edition, Error> {
        apiClientService.request(
            endpoint: SurahEndpoints.getSurahEdition,
            type: Edition.self
        )
    }

    func getSurahList() -> Future<SurahList, Error> {
        apiClientService.request(
            endpoint: SurahEndpoints.getSurahList,
            type: SurahList.self
        )
    }

    func getSurahDetail(
        surahNo: Int,
        recitationId: String,
        translationId: String
    ) -> Future<Surah, Error> {
        apiClientService.request(
            endpoint: SurahEndpoints.getSurahDetail(
                surahNo: surahNo,
                recitationId: recitationId,
                translationId: translationId
            ),
            type: Surah.self
        )
    }
}

final class SurahCatalog {
    static let shared = SurahCatalog()

    private(set) var surahs: [SurahListResponse] = []
    private(set) var isLoaded = false

    private let cacheURL: URL?

    private init() {
        let directory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        cacheURL = directory?.appendingPathComponent("surah-catalog.json")
        loadFromDisk()
    }

    func store(_ surahs: [SurahListResponse]) {
        self.surahs = surahs
        isLoaded = !surahs.isEmpty

        guard let cacheURL,
              let data = try? JSONEncoder().encode(surahs) else {
            return
        }
        try? data.write(to: cacheURL, options: .atomic)
    }

    private func loadFromDisk() {
        guard let cacheURL,
              let data = try? Data(contentsOf: cacheURL),
              let cached = try? JSONDecoder().decode(
                [SurahListResponse].self,
                from: data
              ) else {
            return
        }
        surahs = cached
        isLoaded = !cached.isEmpty
    }
}
