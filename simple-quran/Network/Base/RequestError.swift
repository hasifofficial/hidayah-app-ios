//
//  RequestError.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/06/2023.
//

import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
}
