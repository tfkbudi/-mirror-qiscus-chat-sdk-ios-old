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
    public var commentBeforeId      : String        = ""
    public var email                : String        = ""
    public var id                   : String        = ""
    public var isDeleted            : Bool          = false
    public var isPublicChannel      : Bool          = false
    public var status               : CommentStatus = .sending
    public var message              : String        = ""
    public var payload              : String?       = nil
    public var extras               : String?       = nil
    public var roomId               : String        = ""
    public var timestamp            : String        = ""
    public var type                 : String        = "text"
    public var uniqueTempId         : String
    public var unixTimestamp        : Int           = 0
    public var userAvatarUrl        : URL?          = nil
    public var userId               : String        = ""
    public var username             : String        = ""
    
//    public static func new(message: String, payload: String) {
//        self.uniqueTempId   = "ios_\(NSDate().timeIntervalSince1970 * 1000.0)"
//        self.message    = message
//        self.payload    = payload
//    }
    
    init(json: JSON) {
        self.id                 = json["id_str"].stringValue
        self.roomId             = json["id_str"].stringValue
        self.uniqueTempId       = json["room_id_str"].stringValue
        self.commentBeforeId    = json["comment_before_id_str"].stringValue
        self.email              = json["email"].stringValue
        self.isDeleted          = json["room_id_str"].boolValue
        self.isPublicChannel    = json["room_id_str"].boolValue
        self.message            = json["message"].stringValue
        self.payload            = json["payload"].stringValue
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
            print("payload \(_payload)")
        }
    }
    
    private func getType(fromPayload data: JSON) -> String {
        let type = data["type"].stringValue
        return type
    }
}

public enum CommentStatus : String {
    case deliver    = "deliver"
    case receipt    = "receipt"
    case read       = "read"
    case sent       = "sent"
    case deleted    = "deleted"
    case sending    = "sending"
    
    static let all = [sent, sending, deliver, receipt, read, deleted]
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
