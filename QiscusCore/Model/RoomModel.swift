//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation

public class RoomCreateGetUpdateResult : Codable {
    let changed: Bool?
    let room : RoomModel
    let comments : [CommentModel]
    
    enum CodingKeys: String, CodingKey {
        case changed = "changed"
        case room = "room"
        case comments = "comments"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        changed = try values.decodeIfPresent(Bool.self, forKey: .changed)
        room = try values.decode(RoomModel.self, forKey: .room)
        comments = try values.decode([CommentModel].self, forKey: .comments)
    }
}

public class RoomsResults : Codable {
    let meta : Meta?
    let roomsInfo : [RoomModel]
    
    enum CodingKeys: String, CodingKey {
        
        case meta = "meta"
        case roomsInfo = "rooms_info"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
        roomsInfo = try values.decode([RoomModel].self, forKey: .roomsInfo)
    }
}

public class AddParticipantsResult : Codable {
    let participantsAdded : [QParticipant]
    
    enum CodingKeys: String, CodingKey {
        case participantsAdded = "participants_added"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        participantsAdded = try values.decode([QParticipant].self, forKey: .participantsAdded)
    }
}

public class Meta : Codable {
    public let currentPage : Int?
    public let totalRoom : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case currentPage = "current_page"
        case totalRoom = "total_room"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try values.decodeIfPresent(Int.self, forKey: .currentPage)
        totalRoom = try values.decodeIfPresent(Int.self, forKey: .totalRoom)
    }
    
}

open class RoomModel : Codable {
    public let id : String
    public let name : String
    public let uniqueId : String
    public let avatarUrl : String
    public let chatType : String
    public let options : String?
    public let lastComment : CommentModel?
    public let participants : [QParticipant]?
    public let unreadCount : Int
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "room_name"
        case uniqueId = "unique_id"
        case avatarUrl = "avatar_url"
        case chatType = "chat_type"
        case options = "options"
        case lastComment = "last_comment"
        case participants = "participants"
        case unreadCount = "unread_count"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = "\(try values.decode(Int.self, forKey: .id))"
        name = try values.decode(String.self, forKey: .name)
        uniqueId = try values.decode(String.self, forKey: .uniqueId)
        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        chatType = try values.decode(String.self, forKey: .chatType)
        options = try values.decodeIfPresent(String.self, forKey: .options)
        lastComment = try values.decodeIfPresent(CommentModel.self, forKey: .lastComment)
        participants = try values.decodeIfPresent([QParticipant].self, forKey: .participants)
        unreadCount = try values.decode(Int.self, forKey: .unreadCount)
    }
}

public class QParticipant : Codable {
    public let avatarUrl : String
    public let email : String
    public let id : String
    public let lastCommentReadId : Int
    public let lastCommentReceivedId : Int
    public let username : String
    
    enum CodingKeys: String, CodingKey {
        
        case avatarUrl = "avatar_url"
        case email = "email"
        case id = "id"
        case lastCommentReadId = "last_comment_read_id"
        case lastCommentReceivedId = "last_comment_received_id"
        case username = "username"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        email = try values.decode(String.self, forKey: .email)
        id = "\(try values.decode(Int.self, forKey: .id))"
        lastCommentReadId = try values.decode(Int.self, forKey: .lastCommentReadId)
        lastCommentReceivedId = try values.decode(Int.self, forKey: .lastCommentReceivedId)
        username = try values.decode(String.self, forKey: .username)
    }
    
}
