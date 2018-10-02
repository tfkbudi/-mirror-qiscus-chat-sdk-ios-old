//
//  QiscusDBManager.swift
//  QiscusCore
//
//  Created by Qiscus on 12/09/18.
//
import Foundation

public class QiscusDatabaseManager {
    static var shared   : QiscusDatabaseManager = QiscusDatabaseManager()
    public var room    : RoomDB!
    public var comment : CommentDB!
    public var member   : MemberDB!
    
    init() {
        self.member     = MemberDB()
        self.room       = RoomDB()
        self.comment    = CommentDB()
    }
    
    func loadData() {
        member.loadData()
        room.loadData()
        comment.loadData()
    }
    
    func clear() {
        QiscusDatabase.clear()
    }
    
}

public class MemberDB {
    private var member : MemberDatabase = MemberDatabase()
    
    // MARK : Internal
    internal func loadData() {
        member.loadData()
    }
    
    internal func save(_ data: [MemberModel], roomID id: String) {
        for m in data {
            guard let room = QiscusCore.database.room.find(id: id) else {
                QiscusLogger.errorPrint("Failed to save member \(data) in db, mybe room not found")
                return
            }
            let roomDB = QiscusCore.database.room.map(room)
            member.add([m], inRoom: roomDB)
        }
    }
    
    // manage relations rooms and member
    internal func map(_ core: MemberModel, data: Member? = nil) -> Member {
        return member.map(core, data: data)
    }
    
    internal func map(member data: Member) -> MemberModel {
        return member.map(data)
    }
    
    // MARK : Public
    // take time, coz search in all rooms
    public func find(byEmail email: String) -> MemberModel? {
//        if let member = comment.find(byUniqueID: id) {
//            return comment
//        }else {
            return member.find(predicate: NSPredicate(format: "email = %@", email))?.first
//        }
    }
    
}

public class RoomDB {
    private var room : RoomStorage = RoomStorage()
    
    // MARK : Private
    internal func loadData() {
        room.loadData()
    }
    
    internal func map(_ core: RoomModel, data: Room? = nil) -> Room {
        return room.map(core, data: data)
    }
    
    internal func save(_ rooms: [RoomModel]) {
        room.add(rooms)
        
        for r in rooms {
            // save member
            guard let participants = r.participants else { return }
            QiscusCore.database.member.save(participants, roomID: r.id)
        }
    }
    
    internal func updateLastComment(_ comment: CommentModel) -> Bool {
        return room.updateLastComment(comment)
    }
    
    internal func updateReadComment(_ comment: CommentModel) -> Bool {
        return room.updateUnreadComment(comment)
    }
    
    // MARK : Private
    public func find(predicate: NSPredicate) -> [RoomModel]? {
        return room.find(predicate: predicate)
    }
    
    public func find(id: String) -> RoomModel? {
        if let room = room.find(byID: id) {
            return room
        }else {
            return find(predicate: NSPredicate(format: "id = %@", id))?.last
        }
    }
    
    public func all() -> [RoomModel] {
        return room.all()
    }
    
}

public class CommentDB {
    private var comment = CommentStorage()
    
    // MARK: Internal
    internal func loadData() {
        comment.loadData()
    }
    
    internal func save(_ data: [CommentModel]) {
        data.forEach { (c) in
            // listen callback to provide event
            comment.add(c, onCreate: { (result) in
                QiscusEventManager.shared.gotNewMessage(comment: c)
            }) { (updatedResult) in
                // MARK : TODO refactor comment update flow and event
                QiscusCore.eventManager.gotMessageStatus(roomID: c.roomId, commentUniqueID: c.uniqId, status: c.status)
            }
        }
        
        // make sure data sort by date
        data.reversed().forEach { (c) in
            // update last comment in room, mean comment where you send
            _ = QiscusCore.database.room.updateLastComment(c)
        }
    }
    
    internal func delete(uniqId id: String) -> Bool {
        // MARK : TODO
        return comment.delete(byUniqueID: id)
    }
    
    // MARK: Public comment
    public func all() -> [CommentModel] {
        return comment.all()
    }

    public func find(predicate: NSPredicate) -> [CommentModel]? {
        return comment.find(predicate: predicate)
    }
    
    public func find(roomId id: String) -> [CommentModel]? {
        if let comments = comment.find(byRoomID: id) {
            return comments
        }else {
            return comment.find(predicate: NSPredicate(format: "roomId = %@", id))
        }
    }

    public func find(id: String) -> CommentModel? {
        if let comment = comment.find(byID: id) {
            return comment
        }else {
            return comment.find(predicate: NSPredicate(format: "id = %@", id))?.first
        }
    }

    public func find(uniqueId id: String) -> CommentModel? {
        if let comment = comment.find(byUniqueID: id) {
            return comment
        }else {
            return comment.find(predicate: NSPredicate(format: "uniqId = %@", id))?.first
        }
    }
}
