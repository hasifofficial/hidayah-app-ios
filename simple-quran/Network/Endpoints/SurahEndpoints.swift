//
//  SurahEndpoints.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 11/06/2023.
//

import Foundation

enum SurahEndpoints {
    case getSurahEdition
    case getSurahList
    case getSurahDetail(surahNo: Int, recitationId: String, translationId: String)
}

extension SurahEndpoints: Endpoint {
    var path: String {
        switch self {
        case .getSurahEdition:
            return "/v1/edition"
        case .getSurahList:
            return "/v1/surah"
        case .getSurahDetail(let surahNo, let recitationId, let translationId):
            return "/v1/surah/\(surahNo)/editions/\(recitationId),\(translationId)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .getSurahEdition, .getSurahList, .getSurahDetail:
            return .get
        }
    }
    
    var header: [String: String]? {
        switch self {
        case .getSurahEdition, .getSurahList, .getSurahDetail:
            return nil
        }
    }
    
    var body: [String: String]? {
        switch self {
        case .getSurahEdition, .getSurahList, .getSurahDetail:
            return nil
        }
    }
}
