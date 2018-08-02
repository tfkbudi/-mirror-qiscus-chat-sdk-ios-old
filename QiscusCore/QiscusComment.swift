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
        //QiscusCore.network.postComment(roomId: id, type: comment.type, comment: <#T##String#>, payload: <#T##String#>, extras: <#T##String#>, uniqueTempId: <#T##String#>, completion: <#T##(QComment?, String?) -> Void#>)
        
        
        QiscusCore.network.postComment(roomId: id, comment: comment.message) { (result, error) in
            if result != nil {
                completion(comment,nil)
            }else {
                completion(nil,QError.init(message: error ?? "Failed to send message"))
            }
        }
    }
    
    public func loadComments(roomID id: String, lastCommentId: Int? = nil, timestamp: String? = nil, after: Bool = false, limit: Int? = nil, completion: @escaping ([QComment]?, QError?) -> Void) {
        QiscusCore.network.loadComments(roomId: id, lastCommentId: lastCommentId, timestamp: timestamp, after: after, limit: limit, completion: { comments, error in
            if comments != nil {
                completion(comments, nil)
            } else {
                completion(comments, QError.init(message: error ?? "Failed to load comment"))
            }
        })
    }
    
    
}
