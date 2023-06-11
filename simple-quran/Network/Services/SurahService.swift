//
//  SurahService.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/06/2023.
//

import Combine

protocol SurahServiceable {
    func getSurahEdition() -> Future<Edition, Error>
    func getSurahList() -> Future<SurahList, Error>
    func getSurahDetail(surahNo: Int, recitationId: String, translationId: String) -> Future<Surah, Error>

}

struct SurahService: SurahServiceable {
    func getSurahEdition() -> Future<Edition, Error> {
        API.shared.request(
            endpoint: SurahEndpoints.getSurahEdition,
            type: Edition.self
        )
    }
    
    func getSurahList() -> Future<SurahList, Error> {
        API.shared.request(
            endpoint: SurahEndpoints.getSurahList,
            type: SurahList.self
        )
    }
    
    func getSurahDetail(
        surahNo: Int,
        recitationId: String,
        translationId: String
    ) -> Future<Surah, Error> {
        API.shared.request(
            endpoint: SurahEndpoints.getSurahDetail(
                surahNo: surahNo,
                recitationId: recitationId,
                translationId: translationId
            ),
            type: Surah.self
        )
    }
}
