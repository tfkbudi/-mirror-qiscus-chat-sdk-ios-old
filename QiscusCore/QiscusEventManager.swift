//
//  QiscusEventManager.swift
//  QiscusCore
//
//  Created by Qiscus on 14/08/18.
//

import Foundation

class QiscusEventManager {
    static var shared : QiscusEventManager = QiscusEventManager()
    // MARK: TODO delegate can't be accees from other class, please create setter/function
    var connectionDelegate : QiscusConnectionDelegate? = nil
    var delegate : QiscusCoreDelegate? = nil
    var roomDelegate : QiscusCoreRoomDelegate? = nil
    var room : RoomModel? = nil
    
    func gotMessageStatus(comment: CommentModel){
        guard let user = QiscusCore.getProfile() else { return }
        if comment.userEmail != user.email { return }
        guard let room = QiscusCore.database.room.find(id: comment.roomId) else { return }
        if let r = QiscusEventManager.shared.room {
            if r.id == room.id {
                roomDelegate?.didComment(comment: comment, changeStatus: comment.status)
            }
        }
    }
    
    func gotNewMessage(comment: CommentModel) {
        // filter event for active room
        if let r = QiscusEventManager.shared.room {
            if r.id == String(comment.roomId) {
                // we assume UI or developer is active listen this room
                _ = QiscusCore.database.room.updateReadComment(comment)
                // publish event new comment inside room
                roomDelegate?.gotNewComment(comment: comment)
            }
        }
        // got new comment for other room
        if let room = QiscusCore.database.room.find(id: comment.roomId) {
            delegate?.onRoom(room, gotNewComment: comment)
        }
        
        // MARK: TODO receive new comment, need trotle
        guard let user = QiscusCore.getProfile() else { return }
        // no update if your comment
        if user.email != comment.userEmail {
            // call api receive, need optimize
            QiscusCore.shared.updateCommentReceive(roomId: comment.roomId, lastCommentReceivedId: comment.id)
        }
    }
    
    func deleteRoom(_ room: RoomModel) {
        delegate?.onRoom(deleted: room)
    }
    
    func deleteComment(_ comment: CommentModel) {
        if let r = QiscusEventManager.shared.room {
            if r.id == String(comment.roomId) {
                roomDelegate?.didDelete(Comment: comment)
            }
        }
        // got new comment for other room
        if let room = QiscusCore.database.room.find(id: comment.roomId) {
            delegate?.onRoom(room, didDeleteComment: comment)
        }
    }
    
    func gotTyping(roomID: String, user: String, value: Bool) {
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == roomID {
                guard let member = QiscusCore.database.member.find(byEmail: user) else { return }
                roomDelegate?.onRoom(thisParticipant: member, isTyping: value)
            }
        }
    }
    
    func gotEvent(email: String, isOnline: Bool, timestamp time: String) {
        guard let member = QiscusCore.database.member.find(byEmail: email) else { return }
        guard let validTime = self.components(time, length: 13).first else { return }
        let date = getDate(timestampUTC: validTime)
        // filter event for room or qiscuscore
        if let room = QiscusEventManager.shared.room  {
            guard let participants = room.participants else { return }
            participants.forEach { (member) in
                if email == member.email {
                    self.roomDelegate?.onChangeUser(member, onlineStatus: isOnline, whenTime: date)
                }
                member.saveLastOnline(date)
            }
        }
    }
    
    private func getDate(timestampUTC: String) -> Date {
        let double = Double(timestampUTC) ?? 0.0
        let date = Date(timeIntervalSince1970: TimeInterval(double/1000))
        return date
    }
    
    func roomUpdate(room: RoomModel) {
        if let r = QiscusEventManager.shared.room {
            if r.id == room.id {
                roomDelegate?.onRoom(update: room)
            }
        }
        delegate?.onRoom(update: room)
    }
    
    func roomNew(room: RoomModel) {
        delegate?.gotNew(room: room)
    }
    
    func components(_ value:String, length: Int) -> [String] {
        return stride(from: 0, to: value.characters.count, by: length).map {
            let start = value.index(value.startIndex, offsetBy: $0)
            let end = value.index(start, offsetBy: length, limitedBy: value.endIndex) ?? value.endIndex
            return String(value[start..<end])
        }
    }
    
    /// check comment exist in local
    ///
    /// - Parameter data: comment object
    /// - Returns: return true if comment is new or not exist in local
//    private func checkNewComment(_ data: CommentModel) -> Bool {
//        return !(QiscusCore.database.comment.find(uniqueId: data.uniqId) != nil)
//    }
}
