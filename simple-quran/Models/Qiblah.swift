//
//  Qiblah.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 5/1/21.
//

import Foundation

struct Qiblah: Codable {
    let code: Int?
    let status: String?
    let data: QiblahResponse?
}

struct QiblahResponse: Codable {
    let latitude: Double?
    let longitude: Double?
    let direction: Double?
}
