//
//  Surah.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Foundation

struct Surah: Codable {
    let code: Int?
    let status: String?
    let data: [SurahResponse]?
}

struct SurahResponse: Codable {
    let number: Int?
    let name: String?
    let englishName: String?
    let englishNameTranslation: String?
    let revelationType: String?
    let numberOfAyahs: Int?
    let ayahs: [Ayah]?
    let edition: EditionResponse?
}

struct Ayah: Codable {
    let number: Int?
    let audio: String?
    let text: String?
    let numberInSurah: Int?
    let juz: Int?
    let manzil: Int?
    let page: Int?
    let ruku: Int?
    let hizbQuarter: Int?
}
