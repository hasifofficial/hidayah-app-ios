//
//  SurahList.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Foundation

struct SurahList: Codable {
    let code: Int?
    let status: String?
    let data: [SurahListResponse]?
}

struct SurahListResponse: Codable {
    let number: Int?
    let name: String?
    let englishName: String?
    let englishNameTranslation: String?
    let numberOfAyahs: Int?
    let revelationType: String?
}
