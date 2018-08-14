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
    case listBloked(page: Int?, limit: Int?)
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
            return "/total_unread_count"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .block, .unblock :
            return .post
        case .listBloked, .unread:
            return .get
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
            var params = [
                "token"                       : AUTHTOKEN,
                ] as [String : Any]
            if let p = page {
                params["page"] = p
            }
            if let l = limit {
                params["limit"] = l
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .unread:
            let param = [
                "token"                       : AUTHTOKEN
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        }
    }
}
