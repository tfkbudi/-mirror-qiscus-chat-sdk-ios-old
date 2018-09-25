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
        self.room       = RoomDB()
        self.comment    = CommentDB()
        self.member     = MemberDB()
    }
    
    func clear() {
        QiscusDatabase.clear()
    }
    
}

public class MemberDB {
    private var member : MemberDatabase = MemberDatabase()
}

public class RoomDB {
    private var room : RoomStorage = RoomStorage()
    
    // MARK : Private
    internal func save(_ rooms: [RoomModel]) {
        room.add(rooms)
    }
    
    internal func updateLastComment(_ comment: CommentModel) -> Bool {
        return room.updateLastComment(comment)
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
    internal func save(_ data: [CommentModel]) {
        comment.add(data)
        // make sure data sort by date
        for comment in data.reversed() {
            // update last comment in room, mean comment where you send
            if !QiscusCore.database.room.updateLastComment(comment) {
                QiscusLogger.errorPrint("filed to update last comment")
            }
        }
    }
    
    internal func read(_ data: CommentModel) {
        // update unread count in room
        if !QiscusCore.database.room.updateLastComment(data) {
            QiscusLogger.errorPrint("filed to update unread count, mybe room not exist")
        }
    }
    
    internal func delete(uniqId id: String) {
        // MARK : TODO
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
