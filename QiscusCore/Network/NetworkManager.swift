//
//  NetworkManager.swift
//  QiscusCore
//
//  Created by Qiscus on 18/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

enum NetworkEnvironment : String {
    case production
    case staging
}

class NetworkManager: NSObject {
    static let environment  : NetworkEnvironment = .production
    static let APPID        : String = ""
    let clientRouter    = Router<CLientAPI>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

// MARK : Client
extension NetworkManager {
    func login() {
        clientRouter.request(.loginRegister) { (<#Data?#>, <#URLResponse?#>, <#Error?#>) in
            <#code#>
        }
    }
    
}
