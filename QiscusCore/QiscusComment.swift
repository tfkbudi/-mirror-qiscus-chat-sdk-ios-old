//
//  QiscusComment.swift
//  QiscusCore
//
//  Created by Qiscus on 25/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

// MARK: Comment Management
extension QiscusCore {
    
    public func sendMessage(roomID id: String, comment: CommentModel, onSuccess: @escaping (CommentModel) -> Void, onError: @escaping (QError) -> Void) {
        // update comment
        let _comment            = comment
        _comment.roomId         = id
        _comment.status         = .sending
        _comment.timestamp      = CommentModel.getTimestamp()
        // check comment type, if not Qiscus Comment set as custom type
        if !_comment.isQiscustype() {
            let _payload    = _comment.payload
            let _type       = _comment.type
            _comment.type = "custom"
            _comment.payload?.removeAll() // clear last payload then recreate
            _comment.payload = ["type" : _type]
            if let payload = _payload {
                _comment.payload!["content"] = payload
            }else {
                _comment.payload!["content"] = ["":""]
            }
        }
        // save in local comment pending
        QiscusCore.database.comment.save([_comment])
        // send message to server
        QiscusCore.network.postComment(roomId: comment.roomId, type: comment.type, message: comment.message, payload: comment.payload, extras: comment.extras, uniqueTempId: comment.uniqId) { (result, error) in
            if let commentResult = result {
                // save in local
                commentResult.status = .sent
                QiscusCore.database.comment.save([commentResult])
                //comment.onChange(commentResult) // view data binding
                onSuccess(commentResult)
            }else {
                let _pending = comment
                _pending.status  = .pending
                QiscusCore.database.comment.save([_pending])
                //comment.onChange(_pending) // view data binding
                onError(QError.init(message: error ?? "Pending to send message"))
            }
        }
    }
    
    /// Load Comment by room
    ///
    /// - Parameters:
    ///   - id: Room ID
    ///   - limit: by default set 20, min 0 and max 100
    ///   - completion: Response new Qiscus Array of Comment Object and error if exist.
    public func loadComments(roomID id: String, limit: Int? = nil, onSuccess: @escaping ([CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
        // Load message by default 20
        QiscusCore.network.loadComments(roomId: id, limit: limit) { (comments, error) in
            if let c = comments {
                // save comment in local
                QiscusCore.database.comment.save(c, publishEvent: false)
                onSuccess(c)
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// Load More Message in room
    ///
    /// - Parameters:
    ///   - roomID: Room ID
    ///   - lastCommentID: last comment id want to load
    ///   - limit: by default set 20, min 0 and max 100
    ///   - completion: Response new Qiscus Array of Comment Object and error if exist.
    public func loadMore(roomID id: String, lastCommentID commentID: Int, limit: Int? = nil, onSuccess: @escaping ([CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
        // Load message from server
        QiscusCore.network.loadComments(roomId: id, lastCommentId: commentID, timestamp: nil, after: nil, limit: limit) { (comments, error) in
            if let c = comments {
                // save comment in local
                QiscusCore.database.comment.save(c, publishEvent: false)
                onSuccess(c)
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// Delete message by id
    ///
    /// - Parameters:
    ///   - uniqueID: comment unique id
    ///   - completion: Response Comments your deleted
    public func deleteMessage(uniqueIDs id: [String], onSuccess: @escaping ([CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.deleteComment(commentUniqueId: id) { (results, error) in
            if let c = results {
                // MARK : delete comment in local
                for comment in c {
                    // delete
                    _ = QiscusCore.database.comment.delete(comment)
                    onSuccess(c)
                }
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// Delete all message in room
    ///
    /// - Parameters:
    ///   - roomID: array of room id
    ///   - completion: Response error if exist
    public func deleteAllMessage(roomID ids: [String], completion: @escaping (QError?) -> Void) {
        if ids.isEmpty {
            completion(QError.init(message: "Parameter can't be empty"))
            return
        }
        var uniqueID : [String] = [String]()
        ids.forEach { (id) in
            if let room = QiscusCore.database.room.find(id: id) {
                uniqueID.append(room.uniqueId)
            }
        }
        
        QiscusCore.shared.deleteAllMessage(roomUniqID: uniqueID, completion: completion)
    }
    
    /// Delete all message in room
    ///
    /// - Parameters:
    ///   - roomUniqID: array of room uniq id
    ///   - completion: Response error if exist
    public func deleteAllMessage(roomUniqID roomIDs: [String], completion: @escaping (QError?) -> Void) {
        QiscusCore.network.clearMessage(roomsUniqueID: roomIDs) { (error) in
            if error == nil {
                // delete comment on local
                roomIDs.forEach({ (id) in
                    if let room = QiscusCore.database.room.find(uniqID: id) {
                        QiscusCore.database.comment.clear(inRoom: room.id)
                        QiscusEventManager.shared.roomUpdate(room: room)
                        room.lastComment = nil
                        QiscusCore.database.room.save([room])
                    }
                })
            }
            completion(error)
        }
    }
    
    /// Search message
    ///
    /// - Parameters:
    ///   - keyword: required, keyword to search
    ///   - roomID: optional, search on specific room by room id
    ///   - lastCommentId: optional, will get comments aafter this id
//    public func searchMessage(keyword: String, roomID: String?, lastCommentId: Int?, onSuccess: @escaping ([CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
//        QiscusCore.network.searchMessage(keyword: keyword, roomID: roomID, lastCommentId: lastCommentId) { (results, error) in
//            if let c = results {
//                onSuccess(c)
//            }else {
//                onError(error ?? QError(message: "Unexpected error"))
//            }
//        }
//    }
    
    /// Mark Comment as read, include comment before
    ///
    /// - Parameters:
    ///   - roomId: room id, where comment cooming
    ///   - lastCommentReadId: comment id
    public func updateCommentRead(roomId: String, lastCommentReadId commentID: String) {
        // update unread comment
        if let comment = QiscusCore.database.comment.find(id: commentID) {
            _ = QiscusCore.database.room.updateReadComment(comment)
        }
        
        QiscusCore.network.updateCommentStatus(roomId: roomId, lastCommentReadId: commentID, lastCommentReceivedId: nil)
    }
    
    /// Mark Comment as received or deliverd, include comment before
    ///
    /// - Parameters:
    ///   - roomId: room id, where comment cooming
    ///   - lastCommentReceivedId: comment id
    public func updateCommentReceive(roomId: String, lastCommentReceivedId commentID: String) {
        QiscusCore.network.updateCommentStatus(roomId: roomId, lastCommentReadId: nil, lastCommentReceivedId: commentID)
    }
    
    /// Get comment status is read or received
    ///
    /// - Parameters:
    ///   - id: comment id
    ///   - completion: return object comment if exist
    public func readReceiptStatus(commentId id: String, onSuccess: @escaping (CommentModel) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.readReceiptStatus(commentId: id) { (comment, error) in
            if let c = comment {
                // save comment in local
                QiscusCore.database.comment.save([c])
                onSuccess(c)
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
}
