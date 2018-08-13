//
//  EndpointUser.swift
//  QiscusCore
//
//  Created by Qiscus on 13/08/18.
//

import Foundation

// MARK: User API
internal enum APIUser {
    case block(email: String)
    case unblock(email: String)
    case listBloked(page: Int, limit: Int)
    case unread()
}

extension APIUser : EndPoint {
    var baseURL: URL {
        return BASEURL
    }
    
    var path: String {
        switch self {
        case .block( _):
            return "/block_user"
        case .unblock( _):
            return "/unblock_user"
        case .listBloked( _, _):
            return "/get_blocked_users"
        case .unread:
            return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .block, .unblock :
            return .post
        case .listBloked :
            return .get
        case .unread:
            <#code#>
        }
    }
    var header: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        switch self {
        case .block(let email):
            let param = [
                "token"                       : AUTHTOKEN,
                "user_email"                  : email
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .unblock(let email):
            let param = [
                "token"                       : AUTHTOKEN,
                "user_email"                  : email
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .listBloked(let page,let limit):
            let param = [
                "token"                       : AUTHTOKEN,
                "page"                        : page,
                "limit"                       : limit
                ] as [String : Any]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        }
    }
}
