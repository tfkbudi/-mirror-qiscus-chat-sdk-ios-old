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
    var task: HTTPTask { get }
}

// MARK: General API
internal enum APIClient {
    case sync(lastReceivedCommentId: Int, order: String, limit: Int)
    case syncEvent(startEventId : Int)
    case search(keyword: String, roomId: Int?, lastCommentId: Int?)
    case registerDeviceToken(token: String)
    case removeDeviceToken(token: String)
    case loginRegister(user: String, password: String , username: String?, avatarUrl: String?)
    case unread
    case upload
 }

var AUTHTOKEN : String {
    get {
        return ""
    }
}

extension APIClient : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
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
        case .unread:
            return "/total_unread_count"
        case .upload:
            return "/upload"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .sync, .syncEvent, .unread:
            return .get
        case .search, .registerDeviceToken, .removeDeviceToken, .loginRegister, .upload:
            return .post
        }
    }
    
    var header: HTTPHeaders? {
        return nil
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
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .syncEvent(let startEventId):
            let param = [
                "token"                       : AUTHTOKEN,
                "start_event_id"              : startEventId
                ] as [String : Any]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .search(let keyword,let roomId,let lastCommentId) :
            var param = [
                "token"                       : AUTHTOKEN,
                "query"                       : keyword
                ] as [String : Any]
            
            if let roomid = roomId{
                param["room_id"] = roomid
            }
            
            if let lastcommentid = lastCommentId{
                param["last_comment_id"] = lastcommentid
            }
            
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .registerDeviceToken(let token):
            let param = [
                "token"                       : AUTHTOKEN,
                "device_token"                : token,
                "device_platform"             : "ios",
                ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .removeDeviceToken(let token):
            let param = [
                "token"                       : AUTHTOKEN,
                "device_token"                : token,
                "device_platform"             : "ios",
                ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
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
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .unread :
            let param = [
                "token"                       : AUTHTOKEN
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        default:
            return .request
        }
    }
}

// MARK: User API
internal enum APIUser {
    case block
    case unblock
    case listBloked
}

extension APIUser : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .block:
            return "/block_user"
        case .unblock:
            return "/unblock_user"
        case .listBloked:
            return "/get_blocked_user"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var header: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        return .request
    }
}

// MARK: Message API
internal enum APIMessage {
    case updateStatus(id: String)
    case delete(id: String)
    case clear
}

extension APIMessage : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .delete( _):
            return "/delete_messages"
        case .clear:
            return "/clear_room_messages"
        case .updateStatus( _):
            return "/update_comment_status"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var header: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        switch self {
        case .delete(let id):
            let params = [
                "token" : AUTHTOKEN,
                "unique_ids" : id
            ]
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        default :
            return .request
        }
    }
}

// MARK: Room API
internal enum APIRoom {
    case roomList
    case roomInfo
    case createNewRoom
    case updateRoom
    case roomWithParticipant()
    case roomWithID()
    case addParticipant
    case removeParticipant
}

extension APIRoom : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .roomList:
            return "/user_rooms"
        case .roomInfo:
            return "/rooms_info"
        case .createNewRoom:
            return "/create_room"
        case .updateRoom:
            return "/update_room"
        case .roomWithParticipant():
            return "/get_or_create_room_with_target"
        case .roomWithID():
            return "/get_or_create_room_with_unique_id"
        case .addParticipant:
            return "/add_room_participants"
        case .removeParticipant:
            return "/remove_room_participants"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var header: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        return .request
    }
}

