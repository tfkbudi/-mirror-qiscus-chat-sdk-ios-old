//
//  CommentModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

public struct Payload: Codable {
    // MARK: todo make sure payload structure
}

public struct Extras: Codable {
    // MARK: todo make sure extras structure
}

public struct QComment : Codable {
    public let commentBeforeId : Int
    public let disableLinkPreview : Bool
    public let email : String
    public let id : String
    public let message: String
    public let payload : Payload?
    public let extras : Extras?
    public let roomId : Int
    public let timestamp : String
    public let topicId : Int
    public let type : String
    public let uniqueTempId : String
    public let unixTimestamp : Int
    public let userAvatarUrl : String
    public let userId : Int
    public let username : String
    
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
    
    public init(from decoder: Decoder) throws {
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
