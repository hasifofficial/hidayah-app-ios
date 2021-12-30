//
//  ApiError.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Foundation

enum ApiError: Error {
    case objectSerialization(reason: String)
    case networkError(reason: String)
    case customError(httpErrorCode: Int?, errorCode: Int?, reason: String?)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .objectSerialization(reason: let reason):
            return reason
        case .networkError(reason: let reason):
            return reason
        case .customError(httpErrorCode: _, errorCode: _, reason: let reason):
            return reason
        }
    }
    
    var errorCode: Int? {
        switch self {
        case .objectSerialization(reason: _):
            return nil
        case .networkError(reason: _):
            return nil
        case .customError(httpErrorCode: _, errorCode: let _errorCode, reason: _):
            return _errorCode
        }
    }
}
