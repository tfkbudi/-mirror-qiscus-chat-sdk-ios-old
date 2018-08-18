//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation

protocol RoomEvent {
    var delegate : QiscusCoreRoomDelegate? { set get }
}

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
    let participantsAdded : [MemberModel]
    
    enum CodingKeys: String, CodingKey {
        case participantsAdded = "participants_added"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        participantsAdded = try values.decode([MemberModel].self, forKey: .participantsAdded)
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

open class RoomModel : Codable, RoomEvent {
    public let id : String
    public let name : String
    public let uniqueId : String
    public let avatarUrl : String
    public let chatType : String
    public let options : String?
    public var lastComment : CommentModel? // can be update after got new comment
    public let participants : [MemberModel]?
    public var unreadCount : Int
    
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
        participants = try values.decodeIfPresent([MemberModel].self, forKey: .participants)
        unreadCount = try values.decode(Int.self, forKey: .unreadCount)
    }
    
    /// set room delegate to get event, and make sure set nil to disable event
    public var delegate: QiscusCoreRoomDelegate? {
        set {
            QiscusEventManager.shared.roomDelegate = newValue
            if newValue != nil {
                QiscusEventManager.shared.room  = self
            }else {
                QiscusEventManager.shared.room  = nil
            }
        }
        get {
            return QiscusEventManager.shared.roomDelegate
        }
    }
}


