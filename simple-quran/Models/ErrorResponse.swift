//
//  ErrorResponse.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Foundation

struct ErrorResponse: Codable {
    let code: Int?
    let status: String?
    let data: String?
}
