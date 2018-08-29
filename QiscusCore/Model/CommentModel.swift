//
//  CommentModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SyncMeta {
    public let last_received_comment_id : Int? = nil
    public let need_clear : Bool? = nil
}

open class CommentModel {
    public var onChange : (CommentModel) -> Void = { _ in} // data binding
    public internal(set) var commentBeforeId      : String        = ""
    public internal(set) var id                   : String        = ""
    public internal(set) var isDeleted            : Bool          = false
    public internal(set) var isPublicChannel      : Bool          = false
    public internal(set) var status               : CommentStatus = .sending
    public var message              : String        = ""
    public var payload              : [String:Any]? = nil
    public var extras               : String?       = nil
    public internal(set) var roomId               : String        = ""
    public internal(set) var timestamp            : String        = ""
    public var type                 : String        = "text"
    public internal(set) var uniqueTempId         : String        = ""
    public internal(set) var unixTimestamp        : Int           = 0
    public internal(set) var userAvatarUrl        : URL?          = nil
    public internal(set) var userId               : String        = ""
    public internal(set) var username             : String        = ""
    public internal(set) var userEmail            : String        = ""
    
    public init() {
        guard let user = QiscusCore.getProfile() else { return }
        self.userId         = String(user.id)
        self.username       = user.username
        self.userAvatarUrl  = user.avatarUrl
        self.userEmail      = user.email
        self.uniqueTempId   = "ios_\(NSDate().timeIntervalSince1970 * 1000.0)"
    }
    
    init(json: JSON) {
        self.id                 = json["id_str"].stringValue
        self.roomId             = json["room_id_str"].stringValue
        self.uniqueTempId       = json["unique_temp_id"].stringValue
        self.commentBeforeId    = json["comment_before_id_str"].stringValue
        self.userEmail          = json["email"].stringValue
        self.isDeleted          = json["room_id_str"].boolValue
        self.isPublicChannel    = json["room_id_str"].boolValue
        self.message            = json["message"].stringValue
        self.payload            = json["payload"].dictionaryObject
        self.extras             = json["extras"].stringValue
        self.timestamp          = json["timestamp"].stringValue
        self.unixTimestamp      = json["unix_timestamp"].intValue
        self.userAvatarUrl      = json["room_avatar"].url ?? URL(string: "http://")
        self.username           = json["username"].stringValue
        self.userId             = json["user_id_str"].stringValue
        let _status             = json["status"].stringValue
        for s in CommentStatus.all {
            if s.rawValue == _status {
                self.status = s
            }
        }
        let _type               = json["type"].stringValue
        if _type != "custom" {
            self.type = _type
        }else {
            self.type = getType(fromPayload: json)
        }
        // parsing payload
        if let _payload = self.payload {
            
        }
    }
    
    private func getType(fromPayload data: JSON) -> String {
        let type = data["type"].stringValue
        return type
    }
}

public enum CommentStatus : String {
    case delivered    = "delivered"
    case receipt    = "receipt"
    case read       = "read"
    case sent       = "sent"
    case deleted    = "deleted"
    case sending    = "sending"
    case failed     = "failed"
    case pending    = "pending"
    
    static let all = [sent, sending, delivered, receipt, read, deleted, failed]
}

public enum CommentType: String, Codable {
    case text                       = "text"
    case fileAttachment              = "file_attachment"
    case accountLink                = "account_linking"
    case buttons                    = "buttons"
    case buttonPostbackResponse     = "button_postback_response"
    case reply                      = "replay"
    case systemEvent                = "system_event"
    case card                       = "card"
    case custom                     = "custom"
    case location                   = "location"
    case contactPerson              = "contactPerson"
    case carousel                   = "carousel"
    
    static let all = [text,fileAttachment,accountLink,buttons,buttonPostbackResponse,reply,systemEvent,card,custom,location,contactPerson,carousel]
}
