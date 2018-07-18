//
//  Endpoint.swift
//  QiscusCore
//
//  Created by Qiscus on 17/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String:String]

protocol EndPoint {
    var baseURL : URL { get }
    var path    : String { get }
    var method  : HTTPMethod { get }
    var header  : HTTPMethods? { get }
}

internal enum CLientAPI {
    case sync
    case syncEvent
    case search
    case setDeviceToken
    case removeDeviceToken
    case loginRegister
    case upload
    case unread
}

extension CLientAPI : EndPoint {
    
}



var BASE_URL: String = ""

struct APOEndPoint {
    var URL : String 
}

internal class APIClientEndpoint {
    static var SYNC: String = BASE_URL + "/sync"
    
    static var SYNC_EVENT: String = BASE_URL + "/sync_event"
    
    static var SEARCH: String = BASE_URL + "/search_messages"
    
    static var SET_DEVICE_TOKEN: String = BASE_URL + "/set_user_device_token"
    
    static var REMOVE_DEVICE_TOKEN: String = BASE_URL + "/remove_user_device_token"
    
    static var LOGIN_REGISTER: String = BASE_URL + "/login_or_register"
    
    static var ALL_UNREAD_COUNT: String = BASE_URL + "/total_unread_count"
    
    static var UPLOAD: String = BASE_URL + "/upload"
}

internal class APIUserEndPoint {
    
        
    static var BLOCK_USER: String = BASE_URL + "/block_user"
        
    static var UNBLOCK_USER: String = BASE_URL + "/unblock_user"
        
    static var LIST_BLOCK_USER: String = BASE_URL + "/get_blocked_user"
}

internal class APIMessage {
    static var DELETE_MESSAGES: String = BASE_URL + "/delete_messages"
    
    static var CLEAR_MESSAGES: String = BASE_URL + "/clear_room_messages"
}

internal class APIRoomEndpoint: NSObject {

    static var ROOMLIST: String = BASE_URL + "/user_rooms"
    
    static var ROOMINFO: String = BASE_URL + "/rooms_info"
    
    static var CREATE_NEW_ROOM: String = BASE_URL
    
    static var ROOM_REQUESTL: String = BASE_URL
    
    static var ROOM_UNIQUEIDL: String = BASE_URL
        
    static var ROOM_REQUEST_ID: String = BASE_URL
    
    static var UPDATE_ROOML: String = BASE_URL
    
    static var UPDATE_COMMENT_STATUS: String = BASE_URL
    
    static var REMOVE_PARTICIPANT: String = BASE_URL
    
    static var ADD_PARTICIPANT: String = BASE_URL

    
    internal class var SYNC_URL:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/sync"
        }
    }
    internal class var SYNC_EVENT_URL:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/sync_event"
        }
    }
    internal class var SEARCH_URL:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/search_messages"
        }
    }
    internal class var ROOMLIST_URL:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/user_rooms"
            
        }
    }
    internal class var ROOMINFO_URL:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/rooms_info"
            
        }
    }
    internal class var SET_DEVICE_TOKEN_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/set_user_device_token"
    }
    internal class var REMOVE_DEVICE_TOKEN_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/remove_user_device_token"
    }
    internal class var UPLOAD_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/upload"
    }
    internal class var UPDATE_ROOM_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/update_room"
    }
    internal class var DELETE_MESSAGES:String{
        get{
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/delete_messages"
        }
    }
    internal class var REMOVE_ROOM_PARTICIPANT: String {
        get {
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/remove_room_participants"
        }
    }
    internal class var ADD_ROOM_PARTICIPANT: String {
        get {
            return "\(QiscusConfig.sharedInstance.BASE_API_URL)/add_room_participants"
        }
    }
    internal class var UPDATE_COMMENT_STATUS_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/update_comment_status"
    }
    internal class var LOGIN_REGISTER:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/login_or_register"
    }
    internal class var CREATE_NEW_ROOM:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/create_room"
    }
    internal class var ROOM_REQUEST_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/get_or_create_room_with_target"
    }
    internal class var ROOM_UNIQUEID_URL:String{
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/get_or_create_room_with_unique_id"
    }
    internal class var ALL_UNREAD_COUNT: String {
        return "\(QiscusConfig.sharedInstance.BASE_API_URL)/total_unread_count"
    }
    open class var LINK_METADATA_URL:String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_API_URL)/get_url_metadata"
    }
    internal class var LOAD_URL:String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_API_URL)/load_comments/"
    }
    internal class var CLEAR_MESSAGES:String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_API_URL)/clear_room_messages/"
    }
    open class func LOAD_URL_(withTopicId topicId:Int, commentId:Int)->String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_API_URL)/topic/\(topicId)/comment/\(commentId)/token/\(config.USER_TOKEN)"
    }
    open class var ROOM_REQUEST_ID_URL:String{
        let config = QiscusConfig.sharedInstance
        return "\(config.BASE_API_URL)/get_room_by_id"
    }

    
}
