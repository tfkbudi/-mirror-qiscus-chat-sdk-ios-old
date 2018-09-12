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
        let comment = Comment.generate()
    }
}

public class RoomDB {
//    public func find(byID id: String) -> RoomModel? {
//        return room.find(byID: id)
//    }
//
//    public func all() -> [RoomModel] {
//        let rooms = room.all()
//        // subscribe
//        QiscusCore.realtime.subscribeRooms(rooms: rooms)
//        return rooms
//    }
}

public class CommentDB {
//    public func all() -> [CommentModel] {
//        return comment.all()
//    }
//
//    public func find(roomId: String) -> [CommentModel]? {
//        return comment.find(byRoomID: id)
//    }
//
//    public func find(id: String) -> CommentModel? {
//        return comment.find(byID: id)
//    }
//
//    public func find(uniqueId: String) -> CommentModel? {
//        return comment.find(byUniqueID: id)
//    }
}
