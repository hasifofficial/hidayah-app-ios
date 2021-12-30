//
//  API.swift
//  simple-quran
//
//  Created by Mohammad Hasif Afiq on 3/24/21.
//

import Alamofire

class API {
    
    private static let networkManager = NetworkReachabilityManager()

    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return SessionManager(configuration: configuration,serverTrustPolicyManager: nil)
    }()
    
    static func networkRechabilityMessage(response: DefaultDataResponse) -> String? {
        guard let networkManager = networkManager else { return nil }
        
        switch networkManager.networkReachabilityStatus {
        case .notReachable:
            return NSLocalizedString("common_error_network_not_reachable", comment: "")
        case .reachable(.ethernetOrWiFi):
            return connectionIssueMessage(response: response)
        case .reachable(.wwan):
            return connectionIssueMessage(response: response)
        case .unknown:
            return NSLocalizedString("common_error_network_not_reachable", comment: "")
        }
    }
    
    static func connectionIssueMessage(response: DefaultDataResponse) -> String? {
        guard let urlError = response.error as? URLError else { return nil }
        
        if urlError.code == .timedOut {
            return  NSLocalizedString("common_error_connection_time_out", comment: "")
        } else if urlError.code == .networkConnectionLost || urlError.code == .unknown || urlError.code == .cannotConnectToHost {
            return NSLocalizedString("common_error_reason", comment: "")
        } else {
            return nil
        }
    }
    
    private static func translateToApiError(responseError: ErrorResponse,
                                            httpResponse: HTTPURLResponse,
                                            dataResponse: DefaultDataResponse? = nil) -> ApiError {
        let error: String = {
            if let errorStr = responseError.data {
                return errorStr
            } else if let dataResponse = dataResponse, let errorStr = networkRechabilityMessage(response: dataResponse) {
                return errorStr
            }
            
            return NSLocalizedString("common_error_content", comment: "")
        }()
        
        let httpErrorCode = httpResponse.statusCode
        let errorCode = responseError.code ?? httpResponse.statusCode
        let errorMessage = responseError.data ?? NSLocalizedString("common_error_content", comment: "")
                        
        if let dataResponse = dataResponse, dataResponse.error != nil, networkManager?.isReachable == false {
            return ApiError.networkError(reason: error)
        } else {
            return ApiError.customError(httpErrorCode: httpErrorCode, errorCode: errorCode, reason: errorMessage)
        }
    }
    
    static func httpErrorHandler(_ response: DefaultDataResponse) -> Result<Data> {
        do {
            guard let data: Data = response.data, let httpResponse = response.response else {
                if let networkError = networkRechabilityMessage(response: response) {
                    return .failure(ApiError.networkError(reason: networkError))
                }

                return .failure(ApiError.objectSerialization(reason: NSLocalizedString("common_error_content", comment: "")))
            }
            
            if httpResponse.statusCode != 200 {
                let responseError = try JSONDecoder().decode(ErrorResponse.self, from: data)
                let apiError = translateToApiError(responseError: responseError, httpResponse: httpResponse, dataResponse: response)
                return .failure(apiError)
            }
            
            return .success(data)
        } catch let error {
            return .failure(ApiError.objectSerialization(reason: error.localizedDescription))
        }
    }
}
