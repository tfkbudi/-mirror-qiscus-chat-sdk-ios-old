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
    
    public func sendMessage(roomID id: String, comment: QComment, completion: @escaping (QComment?, QError?) -> Void) {
        // send message to server
//        QiscusCore.network.postComment(roomId: id, type: comment.type, message: comment.message, payload: comment.payload, extras: comment.extras, uniqueTempId: comment.uniqueTempId) { (result, error) in
//            if result != nil {
//                completion(comment,nil)
//            }else {
//                completion(nil,QError.init(message: error ?? "Failed to send message"))
//            }
//        }
    }
    
    /// Load Comment by room
    ///
    /// - Parameters:
    ///   - id: Room ID
    ///   - limit: by default set 20, min 0 and max 100
    ///   - completion: Response new Qiscus Array of Comment Object and error if exist.
    public func loadComments(roomID id: String, limit: Int? = nil, completion: @escaping ([QComment]?, QError?) -> Void) {
        // Load message by default 20
        QiscusCore.network.loadComments(roomId: id, limit: limit) { (comments, error) in
            completion(comments,nil)
        }
    }
    
    /// Load More Message in room
    ///
    /// - Parameters:
    ///   - roomID: Room ID
    ///   - lastCommentID: last comment id want to load
    ///   - limit: by default set 20, min 0 and max 100
    ///   - completion: Response new Qiscus Array of Comment Object and error if exist.
    public func loadMore(roomID id: String, lastCommentID commentID: Int, limit: Int? = nil, completion: @escaping ([QComment]?, QError?) -> Void) {
        // Load message from server
        QiscusCore.network.loadComments(roomId: id, lastCommentId: commentID, timestamp: nil, after: nil, limit: limit) { (comments, error) in
            completion(comments,nil)
        }
    }
}
