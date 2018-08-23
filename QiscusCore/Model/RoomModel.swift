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
//    let comments : [CommentModel]
    
    enum CodingKeys: String, CodingKey {
        case changed = "changed"
        case room = "room"
//        case comments = "comments"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        changed = try values.decodeIfPresent(Bool.self, forKey: .changed)
        room = try values.decode(RoomModel.self, forKey: .room)
        //comments = try values.decode([CommentModel].self, forKey: .comments)
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
    public var id : String                  = ""
    var idstr : String                      = ""
    public var name : String                = ""
    public var uniqueId : String            = ""
    public var avatarUrl : String           = ""
    public var chatType : String            = ""
    public var options : String?            = ""
    // can be update after got new comment
    public var lastComment : CommentModel?      = nil
    public var participants : [MemberModel]?    = nil
    public var unreadCount : Int                = 0
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case idstr = "id_str"
        case name = "room_name"
        case uniqueId = "unique_id"
        case avatarUrl = "avatar_url"
        case chatType = "chat_type"
        case options = "options"
//        case lastComment = "last_comment"
        case participants = "participants"
        case unreadCount = "unread_count"
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idstr = try values.decodeIfPresent(String.self, forKey: .idstr) ?? ""
        if !idstr.isEmpty {
            id = idstr
        }else {
            id = "\(try values.decodeIfPresent(Int64.self, forKey: .id) ?? -1)"
        }
        name = try values.decode(String.self, forKey: .name)
        uniqueId = try values.decode(String.self, forKey: .uniqueId)
        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        chatType = try values.decode(String.self, forKey: .chatType)
        options = try values.decodeIfPresent(String.self, forKey: .options)
        // lastComment = try values.decodeIfPresent(CommentModel.self, forKey: .lastComment) ?? nil
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


