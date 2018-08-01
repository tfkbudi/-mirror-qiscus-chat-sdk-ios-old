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
        
        QiscusCore.network.postComment(roomId: id, comment: comment.message) { (result, error) in
            if let newComment = result {
                completion(comment,nil)
            }else {
                completion(nil,QError.init(message: error ?? "Failed to send message"))
            }
        }
    }
    
    public func loadComments(roomID id: String, completion: @escaping ([QComment]?, QError?) -> Void) {
        QiscusCore.network.loadComments(roomId: id) { (comments, error) in
            completion(comments,nil)
        }
    }
    
}
