//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation
import SwiftyJSON

protocol RoomEvent {
    var delegate : QiscusCoreRoomDelegate? { set get }
}

//public class RoomCreateGetUpdateResult : Codable {
//    let changed: Bool?
//    let room : RoomModel
////    let comments : [CommentModel]
//    
//    enum CodingKeys: String, CodingKey {
//        case changed = "changed"
//        case room = "room"
////        case comments = "comments"
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        changed = try values.decodeIfPresent(Bool.self, forKey: .changed)
//        room = try values.decode(RoomModel.self, forKey: .room)
//        //comments = try values.decode([CommentModel].self, forKey: .comments)
//    }
//}
//
//public class RoomsResults : Codable {
//    let meta : Meta?
//    let roomsInfo : [RoomModel]
//    
//    enum CodingKeys: String, CodingKey {
//        
//        case meta = "meta"
//        case roomsInfo = "rooms_info"
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
//        roomsInfo = try values.decode([RoomModel].self, forKey: .roomsInfo)
//    }
//}
//
//public class AddParticipantsResult : Codable {
//    let participantsAdded : [MemberModel]
//    
//    enum CodingKeys: String, CodingKey {
//        case participantsAdded = "participants_added"
//    }
//    
//    public required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        participantsAdded = try values.decode([MemberModel].self, forKey: .participantsAdded)
//    }
//}

public class Meta {
    public let currentPage : Int?
    public let totalRoom : Int?
    
    init(json: JSON) {
        self.currentPage    = json["current_page"].intValue
        self.totalRoom    = json["total_room"].intValue
    }
    
}

open class RoomModel : RoomEvent {
    public var onChange : (CommentModel) -> Void = { _ in} // data binding
    public internal(set) var id : String
    public internal(set) var name : String
    public internal(set) var uniqueId : String
    public internal(set) var avatarUrl : URL?
    public internal(set) var chatType : String
    public internal(set) var options : String?
    // can be update after got new comment
    public internal(set) var lastComment : CommentModel?      = nil
    public internal(set) var participants : [MemberModel]?    = nil
    public internal(set) var unreadCount : Int
    
    init(json: JSON) {
        self.id             = json["id_str"].stringValue
        self.name           = json["room_name"].stringValue
        self.uniqueId       = json["unique_id"].stringValue
        self.avatarUrl      = json["avatar_url"].url ?? nil
        self.chatType       = json["chat_type"].stringValue
        self.options        = json["options"].string ?? nil
        self.unreadCount    = json["unread_count"].intValue
        //        case lastComment = "last_comment"
        // case participants = "participants"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case idstr = "id_str"
        case name = "room_name"
        case uniqueId = "unique_id"
        case avatarUrl = "avatar_url"
        case chatType = "chat_type"
        case options = "options"

        case unreadCount = "unread_count"
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


