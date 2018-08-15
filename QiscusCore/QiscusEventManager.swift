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
    
    func gotNewMessage(room: RoomModel?, comment: CommentModel) {
        //delegate?.onRoom(room, gotNewComment: comment)
        if let r = room {
            roomDelegate?.onRoom(r, gotNewComment: comment)
        }
    }
}
