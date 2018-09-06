//
//  QiscusStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 16/08/18.
//
//  Next to be handle all blueprint function by other model, like QiscusStorage/DB

import Foundation

// Blueprint Comment Function
protocol QCCommentManager {
    func saveComment(_ data: CommentModel)
    func saveComments(_ data: [CommentModel])
    func readComment(_ data: CommentModel)
    func getCommentbyRoomID(id: String) -> [CommentModel]?
    func getCommentbyID(id: String) -> CommentModel?
    func getCommentbyUniqueID(id: String) -> CommentModel?
}

// Blueprint room function
protocol QCRoomManager {
    /// Get rooms from local storage
    ///
    /// - Returns: Array of Rooms
    func getRooms() -> [RoomModel]
    /// Save Room
    ///
    /// - Parameter data: room data
    /// - Returns: Void
    func saveRoom(_ data: RoomModel)
    /// save rooms, more than one room data
    ///
    /// - Parameter data: object room
    /// - Returns: Void
    func saveRooms(_ data: [RoomModel])
    /// Remove all room from storage
    ///
    /// - Returns: Void
    func clearRoom()
    /// Find Room
    ///
    /// - Parameter id: room id
    /// - Returns: return Object Room if exist
    func findRoom(byID id: String) -> RoomModel?
}

public class QiscusStorage {
    static var shared   : QiscusStorage = QiscusStorage()
    private var room    : RoomStorage!
    private var comment : CommentStorage!
    let fileManager     : QiscusFileManager = QiscusFileManager()
    
    init() {
        room    = RoomStorage()
        comment = CommentStorage()
    }
    
    // take time, coz search in all rooms
    public func getMember(byEmail email: String) -> MemberModel? {
        let rooms = self.getRooms()
        for room in rooms {
            guard let participants = room.participants else { return nil }
            for p in participants {
                if p.email == email {
                    return p
                }
            }
        }
        return nil
    }
    
    public func getMember(byEmail email: String, inRoom room: RoomModel) -> MemberModel? {
        guard let participants = room.participants else { return nil }
        for p in participants {
            if p.email == email {
                return p
            }
        }
        return nil
    }
}

//  MARK: Room Storage
extension QiscusStorage : QCRoomManager {
    // MARK: remove public next
    public func getRooms() -> [RoomModel] {
        let rooms = room.all()
        // subscribe
        QiscusCore.realtime.subscribeRooms(rooms: rooms)
        return rooms
    }
    
    func saveRoom(_ data: RoomModel) {
        room.add([data])
    }
    
    func saveRooms(_ data: [RoomModel]) {
        room.add(data)
    }
    
    func clearRoom() {
        room.removeAll()
    }
    
    public func findRoom(byID id: String) -> RoomModel? {
        return room.find(byID: id)
    }
}

// MARK: Comment Storage
extension QiscusStorage : QCCommentManager {
    func saveComments(_ data: [CommentModel]) {
        comment.add(data)
    }
    
    public func getComments() -> [CommentModel] {
        return comment.all()
    }
    
    public func getCommentbyRoomID(id: String) -> [CommentModel]? {
        return comment.find(byRoomID: id)
    }
    
    func saveComment(_ data: CommentModel) {
        comment.add([data])
        // update last comment in room, mean comment where you send
        if !room.updateLastComment(data) {
            QiscusLogger.errorPrint("filed to update last comment, mybe room not exist")
        }
    }
    
    func readComment(_ data: CommentModel) {
        // update unread count in room
        if !room.updateUnreadComment(data) {
            QiscusLogger.errorPrint("filed to update unread count, mybe room not exist")
        }
    }
    
    public func getCommentbyID(id: String) -> CommentModel? {
        return comment.find(byID: id)
    }
    
    public func getCommentbyUniqueID(id: String) -> CommentModel? {
        return comment.find(byUniqueID: id)
    }
    
    func clearComment() {
        comment.removeAll()
    }
}
