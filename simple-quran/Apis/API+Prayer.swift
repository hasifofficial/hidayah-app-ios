//
//  API+Prayer.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 4/7/21.
//

import Alamofire

extension API {
    @discardableResult
    static func getTodayPrayerTime(lat: String = "3.251797863827061", long: String = "101.46555678992125", method: Int = 3, _ handler: @escaping (Result<PrayerTime>) -> Void) -> Request {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD-MM-YYYY"
        
        let todayDateInString = dateFormatter.string(from: Date())
        
        let fajrTune = Storage.load(key: .fajrTune) as? Int ?? 1
        let sunriseTune = Storage.load(key: .sunriseTune) as? Int ?? -2
        let dhuhrTune = Storage.load(key: .dhuhrTune) as? Int ?? 2
        let asrTune = Storage.load(key: .asrTune) as? Int ?? 0
        let maghribTune = Storage.load(key: .maghribTune) as? Int ?? 2
        let ishaTune = Storage.load(key: .ishaTune) as? Int ?? 5

        return sessionManager
            .request("https://api.aladhan.com/v1/timings/\(todayDateInString)?latitude=\(lat)&longitude=\(long)&method=\(method)&tune=0,\(fajrTune),\(sunriseTune),\(dhuhrTune),\(asrTune),\(maghribTune),0,\(ishaTune),0")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(PrayerTime.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
    
    @discardableResult
    static func getPrayerTimeForMonth(lat: String = "3.251797863827061", long: String = "101.46555678992125", method: Int = 3, _ handler: @escaping (Result<PrayerTimeForMonth>) -> Void) -> Request {
        
        let fajrTune = Storage.load(key: .fajrTune) as? Int ?? 1
        let sunriseTune = Storage.load(key: .sunriseTune) as? Int ?? -2
        let dhuhrTune = Storage.load(key: .dhuhrTune) as? Int ?? 2
        let asrTune = Storage.load(key: .asrTune) as? Int ?? 0
        let maghribTune = Storage.load(key: .maghribTune) as? Int ?? 2
        let ishaTune = Storage.load(key: .ishaTune) as? Int ?? 5

        return sessionManager
            .request("https://api.aladhan.com/v1/calendar?latitude=\(lat)&longitude=\(long)&method=\(method)&month=\(4)&year=\(2021)&tune=0,\(fajrTune),\(sunriseTune),\(dhuhrTune),\(asrTune),\(maghribTune),0,\(ishaTune),0")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(PrayerTimeForMonth.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
    
    @discardableResult
    static func getQiblahDirection(lat: String = "3.251797863827061", long: String = "101.46555678992125", _ handler: @escaping (Result<Qiblah>) -> Void) -> Request {
        
        return sessionManager
            .request(" https://api.aladhan.com/v1/qibla/\(lat)/\(long)")
            .validate()
            .response { (response) in
                do {
                    let result = httpErrorHandler(response)

                    if result.isFailure, let error = result.error {
                        handler(.failure(error))
                        return
                    }
                    
                    guard let data = result.value else { return }
                    let payload = try JSONDecoder().decode(Qiblah.self, from: data)
                    
                    handler(.success(payload))
                } catch let error {
                    handler(.failure(ApiError.objectSerialization(reason: error.localizedDescription)))
                }
            }
    }
}
