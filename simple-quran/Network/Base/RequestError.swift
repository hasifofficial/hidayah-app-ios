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

    var message: String {
        switch self {
        case .decode:
            return NSLocalizedString(
                "request_error_decode",
                comment: ""
            )
        case .invalidURL:
            return NSLocalizedString(
                "request_error_invalid_url",
                comment: ""
            )
        case .noResponse:
            return NSLocalizedString(
                "request_error_no_response",
                comment: ""
            )
        case .unauthorized:
            return NSLocalizedString(
                "request_error_unauthorized",
                comment: ""
            )
        case .unexpectedStatusCode:
            return NSLocalizedString(
                "request_error_unexpected_status_code",
                comment: ""
            )
        case .unknown:
            return NSLocalizedString(
                "request_error_unknown",
                comment: ""
            )
        }
    }
}
