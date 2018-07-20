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

// MARK: General API
internal enum APIClient {
    case sync(lastReceivedCommentId: Int, order: String, limit: Int)
    case syncEvent(startEventId : Int)
    case search(keyword: String, roomId: Int?, lastCommentId: Int?)
    case registerDeviceToken(token: String)
    case removeDeviceToken(token: String)
    case loginRegister(user: String, password: String , username: String?, avatarUrl: String?)
    case loginRegisterJWT(identityToken: String)
    case nonce
    case unread
    case myProfile
    case updateMyProfile(name: String, avatarUrl: String)
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
        case .loginRegisterJWT( _):
            return "/auth/verify_identity_token"
        case .nonce :
            return "/auth/nonce"
        case .unread:
            return "/total_unread_count"
        case .myProfile:
            return "my_profile"
        case .updateMyProfile :
            return "my_profile"
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
        case .loginRegisterJWT(let identityToken):
            let param = [
                "identity_token"                       : identityToken
                ]
            
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
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
               return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .updateMyProfile(let name,let avatarUrl) :
            let param = [
                "name"                        : name,
                "avatarUrl"                   : avatarUrl,
            ]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        default:
            return .request
        }
    }
}

// MARK: User API
internal enum APIUser {
    case block(email: String)
    case unblock(email: String)
    case listBloked(page: Int, limit: Int)
}

extension APIUser : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .block( _):
            return "/block_user"
        case .unblock( _):
            return "/unblock_user"
        case .listBloked( _, _):
            return "/get_blocked_users"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .block, .unblock :
            return .post
        case .listBloked :
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
            let param = [
                "token"                       : AUTHTOKEN,
                "page"                        : page,
                "limit"                       : limit
                ] as [String : Any]
            return .requestParameters(bodyParameters: param, bodyEncoding: .urlEncoding, urlParameters: nil)
        }
    }
}

// MARK: Message API
internal enum APIMessage {
    case postComment(topicId: String,type: String,comment: String, uniqueTempId: String?) // without payload
    case loadComment(topicId: Int,lastCommentId: Int?,timestamp: String?,after: Bool?,limit: Int?)
    case delete(id: String)
    case updateStatus(roomId: Int,lastCommentReadId: Int?, lastCommentReceivedId: Int?)
    case clear(roomChannelIds: [String])
}

extension APIMessage : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .postComment:
            return "/post_comment"
        case .loadComment:
            return "/load_comments"
        case .delete( _):
            return "/delete_messages"
        case .updateStatus( _, _, _):
            return "/update_comment_status"
        case .clear( _):
            return "/clear_room_messages"
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
        case .postComment(let topicId,let type,let comment,let uniqueTempId):
            var params = [
                "token"                      : AUTHTOKEN,
                "topic_id"                   : topicId,
                "type"                       : type,
                "comment"                    : comment
                ] as [String : Any]
            
            if let uniquetempid = uniqueTempId {
                params["unique_temp_id"] = uniquetempid
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .loadComment(let topicId, let lastCommentId ,let timestamp,let after,let limit):
            var params = [
                "token"                      : AUTHTOKEN,
                "topic_id"                   : topicId
                ] as [String : Any]
            
            if let lastcommentid = lastCommentId {
                params["last_comment_id"] = lastcommentid
            }
            if let timestmp = timestamp {
                params["timestamp"] = timestmp
            }
            if let aftr = after {
                params["after"] = aftr
            }
            if let limt = limit {
                params["limit"] = limt
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .delete(let id):
            let params = [
                "token"                     : AUTHTOKEN,
                "unique_ids"                : id
            ]
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .updateStatus(let roomId,let lastCommentReadId,let lastCommentReceivedId):
            var params = [
                "token"                     : AUTHTOKEN,
                "room_id"                   : roomId
                ] as [String : Any]
            
            if let lastcommentreadid = lastCommentReadId {
                params["last_comment_read_id"] = lastcommentreadid
            }
            
            if let lastcommentreceivedid = lastCommentReceivedId {
                params["last_comment_received_id"] = lastcommentreceivedid
            }
            
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .clear(let roomChannelIds):
            let params = [
                "token"                      : AUTHTOKEN,
                "unique_ids"                 : roomChannelIds
                ] as [String : Any]
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        }
    }
}

// MARK: Room API
internal enum APIRoom {
    case roomList(showParticipants: Bool,limit: Int, page: Int?)
    case roomInfo(roomId: [String]?, roomUniqueId: [String]?, showParticipants: Bool)
    case createNewRoom(name: String,participants: [String],avatarUrl: String?)
    case updateRoom(id: Int, roomName: String?, avatarUrl: String?)
    case roomWithParticipant(email: String, avatarUrl: String?)
    case roomWithID(uniqueId: String,name: String?, avatarUrl: String?)
    case addParticipant(roomId: String, emails: [String])
    case removeParticipant(roomId: String, emails: [String])
    case getRoomById(roomId: Int)
}

extension APIRoom : EndPoint {
    var baseURL: URL {
        guard let url = URL(string: "http://") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .roomList( _, _, _):
            return "/user_rooms"
        case .roomInfo( _, _, _):
            return "/rooms_info"
        case .createNewRoom( _, _, _):
            return "/create_room"
        case .updateRoom( _, _, _):
            return "/update_room"
        case .roomWithParticipant( _, _):
            return "/get_or_create_room_with_target"
        case .roomWithID( _, _, _):
            return "/get_or_create_room_with_unique_id"
        case .addParticipant( _, _):
            return "/add_room_participants"
        case .removeParticipant( _, _):
            return "/remove_room_participants"
        case .getRoomById( _):
            return "/get_room_by_id"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .roomList, .getRoomById:
            return .get
        case .roomInfo, .createNewRoom, .updateRoom, .roomWithParticipant, .roomWithID, .addParticipant, .removeParticipant:
            return .post
        }
    }
    
    var header: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        switch self {
        case .roomList(let showParticipants,let limit,let page):
            var params = [
                "token"                      : AUTHTOKEN,
                "show_participants"          : showParticipants,
                "limit"                      : limit
            ]as [String : Any]
            
            if let pages = page {
                params["page"] = pages
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .roomInfo(let roomId, let roomUniqueId ,let showParticipants) :
            var params = [
                "token"                      : AUTHTOKEN,
                "show_participants"          : showParticipants,
                ]as [String : Any]
            
            if let roomid = roomId {
                params["room_id"] = roomid
            }
            
            if let roomuniqueid = roomUniqueId{
                params["room_unique_id"] = roomuniqueid
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .createNewRoom(let name,let participants,let avatarUrl):
            var params = [
                "token"                      : AUTHTOKEN,
                "name"                       : name,
                "participants"               : participants
                ]as [String : Any]
            
            if let avatarurl = avatarUrl{
                params["avatar_url"] = avatarurl
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .updateRoom(let id,let roomName,let avatarUrl) :
            var params = [
                "token"                      : AUTHTOKEN,
                "id"                         : id,
                ]as [String : Any]
            
            if let roomname = roomName {
                params["room_name"] = roomname
            }
            
            if let avatarurl = avatarUrl {
                params["avatar_url"] = avatarurl
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .roomWithParticipant(let email, let avatarUrl) :
            var params = [
                "token"                      : AUTHTOKEN,
                "email"                      : email
                ]
            
            if let avatarurl = avatarUrl {
                params["avatar_url"] = avatarurl
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .roomWithID(let uniqueId,let name,let avatarUrl):
            var params = [
                "token"                      : AUTHTOKEN,
                "email"                      : uniqueId
            ]
            
            if let nm = name {
                params["name"] = nm
            }
            
            if let avatarurl = avatarUrl {
                params["avatar_url"] = avatarurl
            }
            
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        
        case .addParticipant(let roomId,let emails) :
            let params = [
                "token"                      : AUTHTOKEN,
                "room_id"                    : roomId,
                "emails"                     : emails
                ] as [String : Any]
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .removeParticipant(let roomId,let emails) :
            let params = [
                "token"                      : AUTHTOKEN,
                "room_id"                    : roomId,
                "emails"                     : emails
                ] as [String : Any]
            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        case .getRoomById(let roomId):
            let params = [
                "token"                      : AUTHTOKEN,
                "room_id"                    : roomId
                ] as [String : Any]

            return .requestParameters(bodyParameters: params, bodyEncoding: .urlEncoding, urlParameters: nil)
        }
    }
}

