//
//  NetworkManager.swift
//  QiscusCore
//
//  Created by Qiscus on 18/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

enum NetworkResponse:String {
    case success
    case clientError = "Client Error."
    case serverError = "Server Error."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "Response not JSON or undefined."
}

enum Result<String>{
    case success
    case failure(String)
}

enum NetworkEnvironment : String {
    case production
    case staging
}

public class NetworkManager: NSObject {
    static let environment  : NetworkEnvironment = .production
    static let APPID        : String = ""
    let clientRouter    = Router<APIClient>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        print("response code \(response.statusCode)")
        switch response.statusCode {
        case 200...299: return .success
        case 400...499: return .failure(NetworkResponse.clientError.rawValue)
        case 500...599: return .failure(NetworkResponse.serverError.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

// MARK : Client
extension NetworkManager {
    public func login(email: String, password: String ,username : String? ,avatarUrl : String?, completion: @escaping (String?, String?) -> Void) {
        clientRouter.request(.loginRegister(user: email, password: password,username: username,avatarUrl: avatarUrl)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print("json: \(jsondata)")
                        let apiResponse = try JSONDecoder().decode(UserAPIResponse.self, from: responseData)
                        completion(String(apiResponse.status), nil)
                    }catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    completion(nil,errorMessage)
                }
            }
        }
    }
}
