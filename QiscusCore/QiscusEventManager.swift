//
//  QiscusEventManager.swift
//  QiscusCore
//
//  Created by Qiscus on 14/08/18.
//

import Foundation

class QiscusEventManager {
    static var shared : QiscusEventManager = QiscusEventManager()
    var connectionDelegate : QiscusConnectionDelegate? = nil
    var delegate : QiscusCoreDelegate? = nil
    var roomDelegate : QiscusCoreRoomDelegate? = nil
    var room : RoomModel? = nil
    
    func gotNewMessage(comment: CommentModel) {
        //delegate?.onRoom(room, gotNewComment: comment)
        if let r = QiscusEventManager.shared.room {
            if r.id == String(comment.roomId) {
                // publish event new comment inside room
                roomDelegate?.onRoom(r, gotNewComment: comment)
            }else {
                // got new comment for other room
                if let room = QiscusCore.storage.findRoom(byID: String(comment.roomId)) {
                    delegate?.onRoom(room, gotNewComment: comment)
                }
            }
        }else {
            // got new comment for other room
            if let room = QiscusCore.storage.findRoom(byID: String(comment.roomId)) {
                delegate?.onRoom(room, gotNewComment: comment)
            }
        }
    }
}
