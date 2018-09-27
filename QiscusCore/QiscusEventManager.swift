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
        guard let comment = QiscusCore.database.comment.find(uniqueId: id) else { return }

        // only 3 kind status from realtime read, deliverd, and deleted
        var commentStatus : CommentStatus = status
        switch status {
        case .deleted:
            // update status
            commentStatus = CommentStatus.deleted
            // delete from local
            QiscusCore.database.comment.delete(uniqId: comment.uniqId)
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

        // MARK: TODO check if room single and read by opponent, reduce call API
        
        
        // very tricky, need to review v3, calculating comment status in backend for group rooms
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
                    if lastMyComment.status.hashValue < _comment.status.hashValue {
                        // update all my comment status
                        for c in mycomments {
                            // check lastStatus and compare
                            if c.status.hashValue != _comment.status.hashValue {
                                // update comment
                                c.status = _comment.status
                                QiscusCore.database.comment.save([c])
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
    }
    
    func gotNewMessage(comment: CommentModel) {
        // check comment already in local, if true should be update comment status(not new comment for this device)
        if !self.checkNewComment(comment) { return }
        QiscusCore.database.comment.save([comment])
        // MARK: TODO receive new comment, need trotle
        guard let user = QiscusCore.getProfile() else { return }
        // no update if your comment
        if user.email != comment.userEmail {
            // call api receive, need optimize
            QiscusCore.shared.updateCommentReceive(roomId: comment.roomId, lastCommentReceivedId: comment.id)
        }
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
    }
    
    func gotTyping(roomID: String, user: String, value: Bool) {
        // filter event for room or qiscuscore
        if let r = QiscusEventManager.shared.room {
            if r.id == roomID {
                guard let member = QiscusCore.database.member.find(byEmail: user) else { return }
                roomDelegate?.onRoom(thisParticipant: member, isTyping: value)
            }
        }
        // got typing event for other room
        if let room = QiscusCore.database.room.find(id: roomID) {
            guard let member = QiscusCore.database.member.find(byEmail: user) else { return }
            delegate?.onRoom(room, thisParticipant: member, isTyping: value)
        }
    }
    
    func gotEvent(email: String, isOnline: Bool, timestamp time: String) {
        guard let member = QiscusCore.database.member.find(byEmail: email) else { return }
        let date = getDate(timestampUTC: time)
        // filter event for room or qiscuscore
        if QiscusEventManager.shared.room != nil {
            self.roomDelegate?.onChangeUser(member, onlineStatus: isOnline, whenTime: date)
        }
        self.delegate?.onChange(user: member, isOnline: isOnline, at: date)
    }
    
    private func getDate(timestampUTC: String) -> Date {
        let date = Date(timeIntervalSince1970: Double(timestampUTC) ?? 0.0)
        return date
    }
    
    /// check comment exist in local
    ///
    /// - Parameter data: comment object
    /// - Returns: return true if comment is new or not exist in local
    private func checkNewComment(_ data: CommentModel) -> Bool {
        return !(QiscusCore.database.comment.find(uniqueId: data.uniqId) != nil)
    }
}
