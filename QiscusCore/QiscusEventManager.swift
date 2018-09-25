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
    
    func gotMessageStatus(roomID: String, commentUniqueID id: String, status: CommentStatus){
        guard let room = QiscusCore.database.room.find(id: roomID) else { return }
        guard let comment = QiscusCore.dataStore.getCommentbyUniqueID(id: id) else { return }

        // only 3 kind status from realtime read, deliverd, and deleted
        var commentStatus : CommentStatus = status
        switch status {
        case .deleted:
            // update status
            commentStatus = CommentStatus.deleted
            // delete from local
            QiscusCore.dataStore.deleteComment(uniqueID: comment.uniqId)
            if let r = QiscusEventManager.shared.room {
                if r.id == roomID {
                    roomDelegate?.didComment(comment: comment, changeStatus: commentStatus)
                }
            }
            // got new comment for other room
            delegate?.onRoom(room, didChangeComment: comment, changeStatus: commentStatus)
            break
        default:
            break
        }

        // check comment before, in local then update comment status in this room
        // very tricky, need to review v3
        if let comments = QiscusCore.database.comment.find(roomId: room.id) {
            guard let user = QiscusCore.getProfile() else { return }
            var mycomments = comments.filter({ $0.userEmail == user.email }) // filter my comment
            mycomments = mycomments.filter({ $0.status.hashValue < commentStatus.hashValue }) // filter status < new status
            mycomments = mycomments.sorted(by: { $0.date < $1.date}) // asc
            // call api
            guard let lastMyComment = mycomments.last else { return }
            QiscusCore.shared.readReceiptStatus(commentId: lastMyComment.id) { (result, error) in
                if let _comment = result {
                    // compare current status
                    if lastMyComment.status.hashValue > _comment.status.hashValue {
                        for c in mycomments {
                            // update comment
                            c.status = _comment.status
                            QiscusCore.dataStore.saveComment(c)
                            if let r = QiscusEventManager.shared.room {
                                if r.id == roomID {
                                    self.roomDelegate?.didComment(comment: c, changeStatus: _comment.status)
                                }
                            }
                            // got new comment for other room
                            self.delegate?.onRoom(room, didChangeComment: c, changeStatus: _comment.status)
                        }
                    }
                }
            }
        }
    }
    
    func gotNewMessage(comment: CommentModel) {
        // check comment already in local, if true should be update comment status(not new comment for this device)
        if !self.checkNewComment(comment) { return }
        // update last comment and increase unread
        QiscusCore.dataStore.saveComment(comment)
        // MARK: TODO receive new comment, need trotle
        guard let user = QiscusCore.getProfile() else { return }
        
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == String(comment.roomId) {
                // publish event new comment inside room
                roomDelegate?.gotNewComment(comment: comment)
                // read comment, assume you read from this room
                QiscusCore.dataStore.readComment(comment)
                // no update if your comment
                if user.email != comment.userEmail {
                    // call api receive, need optimize
                    QiscusCore.shared.updateCommentReceive(roomId: r.id, lastCommentReceivedId: comment.id)
                }
            }
        }
        // got new comment for other room
        if let room = QiscusCore.database.room.find(id: comment.roomId) {
            delegate?.onRoom(room, gotNewComment: comment)
            // no update if your comment
            if user.email != comment.userEmail {
                // call api receive, need optimize
                QiscusCore.shared.updateCommentReceive(roomId: room.id, lastCommentReceivedId: comment.id)
            }
        }
    }
    
    func gotTyping(roomID: String, user: String, value: Bool) {
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == roomID {
                guard let member = QiscusCore.dataStore.getMember(byEmail: user) else { return }
                roomDelegate?.onRoom(thisParticipant: member, isTyping: value)
            }
        }
        // got typing event for other room
        if let room = QiscusCore.database.room.find(id: roomID) {
            guard let member = QiscusCore.dataStore.getMember(byEmail: user, inRoom: room) else { return }
            delegate?.onRoom(room, thisParticipant: member, isTyping: value)
        }
    }
    
    func gotEvent(email: String, isOnline: Bool, timestamp time: String) {
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            guard let member = QiscusCore.dataStore.getMember(byEmail: email, inRoom: r) else { return }
            let date = getDate(timestampUTC: time)
            self.roomDelegate?.onChangeUser(member, onlineStatus: isOnline, whenTime: date)
        }
        guard let user = QiscusCore.dataStore.getMember(byEmail: email) else { return }
        let date = getDate(timestampUTC: time)
        self.delegate?.onChange(user: user, isOnline: isOnline, at: date)
    }
    
    private func getDate(timestampUTC: String) -> Date {
        let date = Date(timeIntervalSince1970: Double(timestampUTC) ?? 0.0)
        //        MARK : TODO fix it
//        date.tim
//        let df = DateFormatter()
//        df.timeStyle    = DateFormatter.Style.medium
//        df.dateStyle    = DateFormatter.Style.medium
//        df.timeZone     = TimeZone.current
        return date
    }
    
    /// check comment exist in local
    ///
    /// - Parameter data: comment object
    /// - Returns: return true if comment is new or not exist in local
    private func checkNewComment(_ data: CommentModel) -> Bool {
        return !(QiscusCore.dataStore.getCommentbyUniqueID(id: data.uniqId) != nil)
    }
}
