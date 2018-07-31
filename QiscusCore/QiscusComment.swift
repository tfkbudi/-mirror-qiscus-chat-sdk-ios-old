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
        QiscusCore.network.postComment(roomId: id, type: CommentType(rawValue: comment.type)!, comment: comment.message, payload: "", extras: "", uniqueTempId: comment.uniqueTempId) { (result, error) in
            completion(result,nil)
        }
    }
    
    public func loadComments(roomID id: String, completion: @escaping ([QComment]?, QError?) -> Void) {
        QiscusCore.network.loadComments(roomId: id) { (comments, error) in
            completion(comments,nil)
        }
    }
    
}
