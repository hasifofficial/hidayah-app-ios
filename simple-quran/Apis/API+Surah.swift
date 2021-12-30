//
//  API+Surah.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Alamofire

extension API {
    @discardableResult
    static func getSurahEdition(_ handler: @escaping (Result<Edition>) -> Void) -> Request {
        return sessionManager
            .request("https://api.alquran.cloud/v1/edition")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(Edition.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
    
    @discardableResult
    static func getSurahList(_ handler: @escaping (Result<SurahList>) -> Void) -> Request {
        return sessionManager
            .request("https://api.alquran.cloud/v1/surah")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(SurahList.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
    
    @discardableResult
    static func getSurahDetail(surahNo: Int, recitationId: String, translationId: String, _ handler: @escaping (Result<Surah>) -> Void) -> Request {
        return sessionManager
//            .request("https://api.alquran.cloud/v1/surah/\(surahNo)/editions/ar.alafasy,ms.basmeih")
            .request("https://api.alquran.cloud/v1/surah/\(surahNo)/editions/\(recitationId),\(translationId)")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(Surah.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
}
