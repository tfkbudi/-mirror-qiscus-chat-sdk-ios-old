//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation

public struct RoomCreateResults : Codable {
    let room : QRoom
    let comments : [QComment]
    
    enum CodingKeys: String, CodingKey {
        case room = "room"
        case comments = "comments"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        room = try values.decode(QRoom.self, forKey: .room)
        comments = try values.decode([QComment].self, forKey: .comments)
    }
}

public struct RoomsResults : Codable {
    let meta : Meta?
    let roomsInfo : [QRoom]
    
    enum CodingKeys: String, CodingKey {
        
        case meta = "meta"
        case roomsInfo = "rooms_info"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
        roomsInfo = try values.decode([QRoom].self, forKey: .roomsInfo)
    }
}

public struct Meta : Codable {
    let currentPage : Int?
    let totalRoom : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case currentPage = "current_page"
        case totalRoom = "total_room"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try values.decodeIfPresent(Int.self, forKey: .currentPage)
        totalRoom = try values.decodeIfPresent(Int.self, forKey: .totalRoom)
    }
    
}

public struct QRoom : Codable {
    let id : Int
    let roomName : String
    let uniqueId : String
    let avatarUrl : String
    let chatType : String
    let options : String?
    let lastComment : QComment?
    let participants : [Participants]?
    let unreadCount : Int
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case roomName = "room_name"
        case uniqueId = "unique_id"
        case avatarUrl = "avatar_url"
        case chatType = "chat_type"
        case options = "options"
        case lastComment = "last_comment"
        case participants = "participants"
        case unreadCount = "unread_count"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        roomName = try values.decode(String.self, forKey: .roomName)
        uniqueId = try values.decode(String.self, forKey: .uniqueId)
        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        chatType = try values.decode(String.self, forKey: .chatType)
        options = try values.decodeIfPresent(String.self, forKey: .options)
        lastComment = try values.decodeIfPresent(QComment.self, forKey: .lastComment)
        participants = try values.decodeIfPresent([Participants].self, forKey: .participants)
        unreadCount = try values.decode(Int.self, forKey: .unreadCount)
    }
}

struct Participants : Codable {
    let avatarUrl : String?
    let email : String?
    let id : Int?
    let lastCommentReadId : Int?
    let lastCommentReceivedId : Int?
    let username : String?
    
    enum CodingKeys: String, CodingKey {
        
        case avatarUrl = "avatar_url"
        case email = "email"
        case id = "id"
        case lastCommentReadId = "last_comment_read_id"
        case lastCommentReceivedId = "last_comment_received_id"
        case username = "username"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        lastCommentReadId = try values.decodeIfPresent(Int.self, forKey: .lastCommentReadId)
        lastCommentReceivedId = try values.decodeIfPresent(Int.self, forKey: .lastCommentReceivedId)
        username = try values.decodeIfPresent(String.self, forKey: .username)
    }
    
}
