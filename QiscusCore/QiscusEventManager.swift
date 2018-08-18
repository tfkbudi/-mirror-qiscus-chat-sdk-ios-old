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
    
    func gotNewMessage(comment: CommentModel) {
        // update last comment and increase unread
        QiscusCore.storage.saveComment(comment)
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == String(comment.roomId) {
                // publish event new comment inside room
                roomDelegate?.onRoom(r, gotNewComment: comment)
                // read comment, assume you read from this room
                QiscusCore.storage.readComment(comment)
            }
        }
        // got new comment for other room
        if let room = QiscusCore.storage.findRoom(byID: String(comment.roomId)) {
            delegate?.onRoom(room, gotNewComment: comment)
        }
    }
    
    func gotTyping(roomID: String, user: String, value: Bool) {
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == roomID {
//                let m = ParticipantModel()
//                
//                roomDelegate?.onRoom(thisParticipant: m, isTyping: value)
            }
        }
        // got typing event for other room
        if let room = QiscusCore.storage.findRoom(byID: roomID) {
            
        }
    }
    
    func gotEvent(email: String, isOnline: Bool, timestamp time: String) {
//        let user = UserModel()
//        let date = getDate(timestampUTC: time)
//        self.delegate?.onChange(user: user, isOnline: isOnline, at: date)
    }
    
    private func getDate(timestampUTC: String) -> Date {
        return Date()
    }
}
