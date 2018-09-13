//
//  QiscusDBManager.swift
//  QiscusCore
//
//  Created by Qiscus on 12/09/18.
//
import QiscusDatabase

public class QiscusDatabaseManager {
    static var shared   : QiscusDatabaseManager = QiscusDatabaseManager()
    public var room    : RoomDB!
    public var comment : CommentDB!
    
    init() {
        self.room = RoomDB()
        self.comment = CommentDB()
    }
    
    func clear() {
        QiscusDatabase.clear()
    }
}

public class RoomDB {
    private var room : RoomStorage = RoomStorage()
    
    public func find(predicate: NSPredicate) -> [RoomModel]? {
        return room.find(predicate: predicate)
    }

    public func all() -> [RoomModel] {
        let rooms = room.all()
        return rooms
    }
    
}

public class CommentDB {
    private var comment = CommentStorage()
    
    public func all() -> [CommentModel] {
        return comment.all()
    }

    public func find(roomId id: String) -> [CommentModel]? {
        return comment.find(byRoomID: id)
    }

    public func find(id: String) -> CommentModel? {
        return comment.find(byID: id)
    }

    public func find(uniqueId id: String) -> CommentModel? {
        return comment.find(byUniqueID: id)
    }
}
