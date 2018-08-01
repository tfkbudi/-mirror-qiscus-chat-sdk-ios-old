//
//  CommentModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

class PostCommentResults : Codable {
    let comment : QComment
    
    enum CodingKeys: String, CodingKey {
        
        case comment = "comment"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comment = try values.decode(QComment.self, forKey: .comment)
    }
    
}

public class SyncResults : Codable {
    public let comments : [QComment]
    public let meta : SyncMeta
    
    enum CodingKeys: String, CodingKey {
        
        case comments = "comments"
        case meta = "meta"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comments = try values.decode([QComment].self, forKey: .comments)
        meta = try values.decode(SyncMeta.self, forKey: .meta)
    }
    
}

public class CommentsResults : Codable {
    let comments : [QComment]
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comments = try values.decode([QComment].self, forKey: .comments)
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

open class QComment : Codable {
    public var commentBeforeId : Int = 0
    public var disableLinkPreview : Bool = false
    public var email : String = ""
    public var id : String = ""
    public var message: String = ""
    public var payload : Payload? = nil
    public var extras : Extras? = nil
    public var roomId : Int = 0
    public var timestamp : String = ""
    public var topicId : Int = 0
    public var type : String = ""
    public var uniqueTempId : String = ""
    public var unixTimestamp : Int = 0
    public var userAvatarUrl : String = ""
    public var userId : Int = 0
    public var username : String = ""
    
    enum CodingKeys: String, CodingKey {
        
        case commentBeforeId = "comment_before_id"
        case disableLinkPreview = "disable_link_preview"
        case email = "email"
        case id = "id"
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
    public init() {
        
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        commentBeforeId = try values.decode(Int.self, forKey: .commentBeforeId)
        disableLinkPreview = try values.decode(Bool.self, forKey: .disableLinkPreview)
        email = try values.decode(String.self, forKey: .email)
        id = "\(try values.decode(Int.self, forKey: .id))"
        message = try values.decode(String.self, forKey: .message)
        payload = try values.decodeIfPresent(Payload.self, forKey: .payload)
        extras = try values.decodeIfPresent(Extras.self, forKey: .extras)
        roomId = try values.decode(Int.self, forKey: .roomId)
        timestamp = try values.decode(String.self, forKey: .timestamp)
        topicId = try values.decode(Int.self, forKey: .topicId)
        type = try values.decode(String.self, forKey: .type)
        uniqueTempId = try values.decode(String.self, forKey: .uniqueTempId)
        unixTimestamp = try values.decode(Int.self, forKey: .unixTimestamp)
        userAvatarUrl = try values.decode(String.self, forKey: .userAvatarUrl)
        userId = try values.decode(Int.self, forKey: .userId)
        username = try values.decode(String.self, forKey: .username)
    }

}

public enum CommentType: String, Codable {
    case text = "text"
    case image = "image"
}
