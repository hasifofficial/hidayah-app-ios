//
//  APIClientService.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 02/11/2026.
//

import Foundation
import Combine

class APIClientService {
    private var cancellables = Set<AnyCancellable>()

    func request<T: Codable>(
        endpoint: Endpoint,
        type: T.Type
    ) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self else {
                return promise(.failure(RequestError.unknown))
            }

            var urlComponents = URLComponents()
            urlComponents.scheme = endpoint.scheme
            urlComponents.host = endpoint.host
            urlComponents.path = endpoint.path

            guard let url = urlComponents.url else {
                return promise(.failure(RequestError.invalidURL))
            }

            var request = URLRequest(
                url: url
            )
            request.httpMethod = endpoint.method.rawValue
            request.allHTTPHeaderFields = endpoint.header

            if let body = endpoint.body {
                request.httpBody = try? JSONSerialization.data(
                    withJSONObject: body,
                    options: []
                )
            }

            URLSession.shared.dataTaskPublisher(
                for: request
            ).tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse else {
                    throw RequestError.noResponse
                }

                #if DEBUG
                print("⬅️⬅️⬅️⬅️⬅️ Request:")
                print("🎯 Endpoint: \(url)")
                print("👤 Header: \(endpoint.header ?? [:])")
                if let requestBody = endpoint.body,
                   let jsonData = try? JSONSerialization.data(
                        withJSONObject: requestBody,
                        options: .prettyPrinted
                   ),
                   let jsonString = String(
                        data: jsonData,
                        encoding: .utf8
                   ) {
                    print("📦 Body: \(jsonString)")
                }
                print("⚙️ Method: \(endpoint.method.rawValue)")
                print("➡️➡️➡️➡️➡️ Response:")
                print("🔢 Status code: \(response.statusCode)")
                let headerString = response.allHeaderFields.map { "\"\($0.key)\": \"\($0.value)\"" }.joined(separator: ", ")
                print("👤 Header: [\(headerString)]")
                #endif

                switch response.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw RequestError.unauthorized
                default:
                    throw RequestError.unexpectedStatusCode
                }
            }
            .decode(
                type: type,
                decoder: JSONDecoder()
            )
            .sink(receiveCompletion: { [weak self] completion in
                guard self != nil else {
                    return promise(.failure(RequestError.unknown))
                }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { [weak self] value in
                guard self != nil else {
                    return promise(.failure(RequestError.unknown))
                }

                #if DEBUG
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                if let jsonData = try? encoder.encode(value),
                   let jsonString = String(
                        data: jsonData,
                        encoding: .utf8
                   ) {
                    print("📦 Payload: \(jsonString)")
                } else {
                    print("📦 Payload: \(value)")
                }
                #endif

                promise(.success(value))
            })
            .store(in: &self.cancellables)
        }
    }
}
