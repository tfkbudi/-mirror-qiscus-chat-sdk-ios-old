//
//  CommentModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

class PostCommentResults : Codable {
    let comment : CommentModel
    
    enum CodingKeys: String, CodingKey {
        
        case comment = "comment"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comment = try values.decode(CommentModel.self, forKey: .comment)
    }
    
}

public class SyncResults : Codable {
    public let comments : [CommentModel]
    public let meta : SyncMeta
    
    enum CodingKeys: String, CodingKey {
        
        case comments = "comments"
        case meta = "meta"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comments = try values.decode([CommentModel].self, forKey: .comments)
        meta = try values.decode(SyncMeta.self, forKey: .meta)
    }
    
}

public class CommentsResults : Codable {
    let comments : [CommentModel]
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comments = try values.decode([CommentModel].self, forKey: .comments)
    }
    
}

public class SyncMeta : Codable {
    public let last_received_comment_id : Int?
    public let need_clear : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case last_received_comment_id = "last_received_comment_id"
        case need_clear = "need_clear"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        last_received_comment_id = try values.decodeIfPresent(Int.self, forKey: .last_received_comment_id)
        need_clear = try values.decodeIfPresent(Bool.self, forKey: .need_clear)
    }
    
}


public class Payload: Codable {
    // MARK: todo make sure payload classure
}

public class Extras: Codable {
    // MARK: todo make sure extras classure
}

open class CommentModel : Codable {
    public var commentBeforeId : Int = 0
    public var disableLinkPreview : Bool = false
    public var email : String = ""
    public var id : String = ""
    public var isDeleted: Bool = false
    public var isPublicChannel: Bool = false
    public var status: String = ""
    public var message: String = ""
    public var payload : Payload? = nil
    public var extras : Extras? = nil
    public var roomId : Int = 0
    public var timestamp : String = ""
    public var topicId : Int = 0
    public var type : CommentType = .text
    public var uniqueTempId : String = "ios_"
    public var unixTimestamp : Int = 0
    public var userAvatarUrl : URL? = nil
    public var userId : Int = 0
    public var username : String = ""
    public var coder : Decoder? = nil
    
    enum CodingKeys: String, CodingKey {
        case commentBeforeId = "comment_before_id"
        case disableLinkPreview = "disable_link_preview"
        case email = "email"
        case id = "id"
        case isDeleted = "is_deleted"
        case isPublicChannel = "is_public_channel"
        case status = "status"
        case message = "message"
        case payload = "payload"
        case extras = "extras"
        case roomId = "room_id"
        case timestamp = "timestamp"
        case topicId = "topic_id"
        case type = "type"
        case uniqueTempId = "unique_temp_id"
        case unixTimestamp = "unix_timestamp"
        case userAvatarUrl = "user_avatar_url"
        case userId = "user_id"
        case username = "username"
    }
    
    public init() { }
    
    public required init(from decoders: Decoder) throws {
        let values = try decoders.container(keyedBy: CodingKeys.self)
        commentBeforeId = try values.decode(Int.self, forKey: .commentBeforeId)
        disableLinkPreview = try values.decode(Bool.self, forKey: .disableLinkPreview)
        email = try values.decode(String.self, forKey: .email)
        id = "\(try values.decode(Int.self, forKey: .id))"
        isDeleted = try values.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        isPublicChannel = try values.decode(Bool.self, forKey: .isPublicChannel)
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        message = try values.decode(String.self, forKey: .message)
        
        extras = try values.decodeIfPresent(Extras.self, forKey: .extras)
        roomId = try values.decode(Int.self, forKey: .roomId)
        timestamp = try values.decode(String.self, forKey: .timestamp)
        topicId = try values.decode(Int.self, forKey: .topicId)
        uniqueTempId = try values.decode(String.self, forKey: .uniqueTempId)
        unixTimestamp = try values.decode(Int.self, forKey: .unixTimestamp)
        userAvatarUrl = try values.decode(URL.self, forKey: .userAvatarUrl)
        userId = try values.decode(Int.self, forKey: .userId)
        username = try values.decode(String.self, forKey: .username)
        
        let typeString = try values.decode(String.self, forKey: .type)
        for i in CommentType.all {
            if i.rawValue == typeString {
                type = i
            }
        }
        
        switch type {
        case .fileAttachment:
            payload = try values.decodeIfPresent(PayloadFile.self, forKey: .payload)
        case .location:
            payload = try values.decodeIfPresent(PayloadLocation.self, forKey: .payload)
        case .contactPerson:
            payload = try values.decodeIfPresent(PayloadContact.self, forKey: .payload)
        default:
            break
        }
        
        
        coder = decoders
    }

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
