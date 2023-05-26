//
//  Edition.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/27/21.
//

import Foundation

struct Edition: Codable {
    let code: Int?
    let status: String?
    let data: [EditionResponse]?
}

struct EditionResponse: Codable {
    let identifier: String?
    let language: String?
    let name: String?
    let englishName: String?
    let format: Format?
    let type: String?
    let direction: TextDirection?
}

enum TextDirection: String, Codable {
    case leftToRight = "ltr"
    case rightToLeft = "rtl"
}

enum Format: String, Codable {
    case text
    case audio
}
