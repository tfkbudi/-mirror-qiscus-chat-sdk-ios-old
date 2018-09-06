//
//  Endpoint.swift
//  QiscusCore
//
//  Created by Qiscus on 17/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

protocol EndPoint {
    var baseURL     : URL { get }
    var path        : String { get }
    var httpMethod  : HTTPMethod { get }
    var header      : HTTPHeaders? { get }
    var task        : HTTPTask { get }
}

// MARK: TODO Manage This
var AUTHTOKEN : String {
    get {
        if let user = ConfigManager.shared.user {
            return user.token
        }else {
            return ""
        }
        
    }
}

var BASEURL : URL {
    get {
        if let server = ConfigManager.shared.server {
            return server.url
        }else {
            return URL.init(string: "https://api.qiscus.com/api/v2/mobile")!
        }
    }
}

var HEADERS : [String: String] {
    get {
        var headers = [
            "QISCUS_SDK_PLATFORM": "iOS",
            "QISCUS_SDK_DEVICE_BRAND": "Apple",
            ]
        if let appID = ConfigManager.shared.appID {
            headers["QISCUS_SDK_APP_ID"] = appID
        }
        
        if let user = ConfigManager.shared.user {
            if let appid = ConfigManager.shared.appID {
                headers["QISCUS_SDK_APP_ID"] = appid
            }
            if !user.token.isEmpty {
                headers["QISCUS_SDK_TOKEN"] = user.token
            }
            if !user.email.isEmpty {
                headers["QISCUS_SDK_USER_ID"] = user.email
            }
        }

        return headers
    }
}
/////


// MARK: General API
internal enum APIClient {
    case sync(lastReceivedCommentId: String, order: String, limit: Int)
    case syncEvent(startEventId : Int)
    case search(keyword: String, roomId: String?, lastCommentId: Int?)
    case registerDeviceToken(token: String) //
    case removeDeviceToken(token: String) //
    case loginRegister(user: String, password: String , username: String?, avatarUrl: String?) //
    case loginRegisterJWT(identityToken: String) //
    case nonce //
    case unread
    case myProfile //
    case updateMyProfile(name: String?, avatarUrl: String?) //
    case upload()
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
extension APIClient : EndPoint {
    var baseURL: URL {
       return BASEURL
    }
    
    var path: String {
        switch self {
        case .sync( _, _, _):
            return "/sync"
        case .syncEvent( _):
            return "/sync_event"
        case .search( _, _, _):
            return "/search_messages"
        case .registerDeviceToken( _):
            return "/set_user_device_token"
        case .removeDeviceToken( _):
            return "/remove_user_device_token"
        case .loginRegister( _, _, _, _):
            return "/login_or_register"
        case .loginRegisterJWT( _):
            return "/auth/verify_identity_token"
        case .nonce :
            return "/auth/nonce"
        case .unread:
            return "/total_unread_count"
        case .myProfile:
            return "/my_profile"
        case .updateMyProfile( _, _):
            return "/my_profile"
        case .upload:
            return "/upload"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .sync, .syncEvent, .unread, .myProfile:
            return .get
        case .search, .registerDeviceToken, .removeDeviceToken, .loginRegister, .loginRegisterJWT, .upload, .nonce:
            return .post
        case .updateMyProfile :
            return .patch
        }
    }
    
    var header: HTTPHeaders? {
        return HEADERS
    }
    
    var task: HTTPTask {
        switch self {
        case .sync(let lastReceivedCommentId ,let order, let limit) :
            let param = [
                "token"                       : AUTHTOKEN,
                "last_received_comment_id"    : lastReceivedCommentId,
                "order"                       : order,
                "limit"                       : limit //found in sdk qiscus not from documentation
                ] as [String : Any]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: param)
        case .syncEvent(let startEventId):
            let param = [
                "token"                       : AUTHTOKEN,
                "start_event_id"              : startEventId
                ] as [String : Any]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: param)
        case .search(let keyword,let roomId,let lastCommentId) :
            var param = [
                "token"                       : AUTHTOKEN,
                "query"                       : keyword
                ] as [String : Any]
            
            if let roomid = roomId {
                param["room_id"] = roomid
            }
            
            if let lastcommentid = lastCommentId {
                param["last_comment_id"] = lastcommentid
            }
            
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .registerDeviceToken(let token):
            let param = [
                "token"                       : AUTHTOKEN,
                "device_token"                : token,
                "device_platform"             : "ios",
                ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .removeDeviceToken(let token):
            let param = [
                "token"                       : AUTHTOKEN,
                "device_token"                : token,
                "device_platform"             : "ios",
                ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .loginRegister(let user, let password, let username, let avatarUrl):
            var param = [
                "email"                       : user,
                "password"                    : password,
                "device_platform"             : "ios",
            ]
            
            if let usernm = username {
                param["username"] = usernm
            }
            if let avatarurl = avatarUrl{
                param["avatar_url"] = avatarurl
            }
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .loginRegisterJWT(let identityToken):
            let param = [
                "identity_token"                       : identityToken
                ]
            
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .nonce :
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .unread :
            let param = [
                "token"                       : AUTHTOKEN
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .myProfile :
            let param = [
                "token"                       : AUTHTOKEN
            ]
               return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: param)
        case .updateMyProfile(let name,let avatarUrl) :
            var param = [
                "token"                       : AUTHTOKEN,
            ]
            
            if let newName = name {
                param["name"] = newName
            }
            
            if let newAvatarUrl = avatarUrl {
                param["avatar_url"] = newAvatarUrl
            }
            
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .upload() :
            let param = [
                "token" : AUTHTOKEN
                ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .jsonEncoding, urlParameters: nil)
        }
    }
}
