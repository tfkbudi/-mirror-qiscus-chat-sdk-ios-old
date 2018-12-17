//
//  NetworkMessage.swift
//  QiscusCore
//
//  Created by Qiscus on 14/08/18.
//

import Foundation

// MARK: Comment
extension NetworkManager {
    
    /// load comments on a room or channel
    ///
    /// - Parameters:
    ///   - roomId: room id or unique id
    ///   - lastCommentId: last recieved comment id before loadmore
    ///   - timestamp: timestamp
    ///   - after: if true returns comments with id >= last_comment_id. if false and last_comment_id is specified, returns last 20 comments with id < last_comment_id. if false and last_comment_id is not specified, returns last 20 comments
    ///   - limit: limit for the result default value is 20, max value is 100
    ///   - completion: @escaping when success load comments, return Optional([CommentModel]) and Optional(String error message)
    func loadComments(roomId: String, lastCommentId: Int? = nil, timestamp: String? = nil, after: Bool? = nil, limit: Int? = nil, completion: @escaping ([CommentModel]?, QError?) -> Void) {
        commentRouter.request(.loadComment(topicId: roomId, lastCommentId: lastCommentId, timestamp: timestamp, after: after, limit: limit)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let comments = CommentApiResponse.comments(from: response)
                    completion(comments, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    completion(nil, QError(message: errorMessage))
                }
            }
        }
    }
    
    
    /// post comment
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - type: comment type
    ///   - comment: comment text (required when type == text)
    ///   - payload: comment payload (string on json format)
    ///   - extras: comment extras (string on json format)
    ///   - uniqueTempId: -
    ///   - completion: @escaping when success post comment, return Optional(CommentModel) and Optional(String error message)
    func postComment(roomId: String, type: String = "text", message: String, payload: [String:Any]? = nil, extras: [String:Any]? = nil, uniqueTempId: String = "", completion: @escaping(CommentModel?, String?) -> Void) {
        commentRouter.request(.postComment(topicId: roomId, type: type, message: message, payload: payload, extras: extras, uniqueTempId: uniqueTempId)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let comment = CommentApiResponse.comment(from: response)
                    completion(comment, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        completion(nil, errorMessage)
                    } catch {
                        completion(nil, errorMessage)
                    }
                }
            }
        }
    }
    
    
    /// delete comments
    ///
    /// - Parameters:
    ///   - commentUniqueId: comment unique id or you can use comment.uniqueTempId
    ///   - completion: @escaping when success delete comments, return deleted comment Optional([CommentModel]) and Optional(String error message)
    func deleteComment(commentUniqueId: [String], completion: @escaping ([CommentModel]?, QError?) -> Void) {
        commentRouter.request(.delete(commentUniqueId: commentUniqueId)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let comments = CommentApiResponse.comments(from: response)
                    completion(comments, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, QError(message: errorMessage))
                }
            }
        }
    }
    
    // todo: add more documentation
    func updateCommentStatus(roomId: String, lastCommentReadId: String? = nil, lastCommentReceivedId: String? = nil) {
        commentRouter.request(.updateStatus(roomId: roomId, lastCommentReadId: lastCommentReadId, lastCommentReceivedId: lastCommentReceivedId)) { (data, response, error) in
            
        }
    }
    
    /// Get total unread message
    ///
    /// - Parameter completion: result as Int
    func unreadCount(completion: @escaping(Int, QError?) -> Void) {
        userRouter.request(.unread()) { (data, response, error) in
            if error != nil {
                completion(0, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(0, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let unread = ApiResponse.decode(unread: responseData)
                    completion(unread,nil)
                case .failure(let errorMessage):
                    completion(0, QError(message: "Can't parse error, when request unread count."))
                }
            }
        }
    }
    
    /// Search message from server
    ///
    /// - Parameters:
    ///   - keyword: required, keyword to search
    ///   - roomID: optional, search on specific room by room id
    ///   - lastCommentId: optional, will get comments aafter this id
    func searchMessage(keyword: String, roomID: String?, lastCommentId: Int?, completion: @escaping ([CommentModel]?, QError?) -> Void) {
        commentRouter.request(.search(keyword: keyword, roomID: roomID, lastCommentID: lastCommentId)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let comments = CommentApiResponse.comments(from: response)
                    completion(comments, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    completion(nil, QError(message: errorMessage))
                }
            }
        }
    }
    
    /// Clear message from
    ///
    /// - Parameters:
    ///   - roomsID: room id where you want to clear
    ///   - completion: got error if exist
    func clearMessage(roomsID: [String], completion: @escaping (QError?) -> Void) {
        if roomsID.isEmpty {
            completion(QError.init(message: "Parameter can't be empty"))
        }
        var uniqueID : [String] = [String]()
        roomsID.forEach { (id) in
            if let room = QiscusCore.database.room.find(id: id) {
                uniqueID.append(room.uniqueId)
            }
        }
        self.clearMessage(roomsUniqueID: uniqueID, completion: completion)
    }
    
    /// Clear message from
    ///
    /// - Parameters:
    ///   - roomsUniqueID: room unique id where you want to clear
    ///   - completion: got error if exist
    func clearMessage(roomsUniqueID: [String], completion: @escaping (QError?) -> Void) {
        if roomsUniqueID.isEmpty {
            completion(QError.init(message: "Parameter can't be empty"))
        }
        commentRouter.request(.clear(roomChannelIds: roomsUniqueID)) { (data, response, error) in
            if error != nil {
                completion(QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    // delete comment on local
                    roomsUniqueID.forEach({ (id) in
                        if let room = QiscusCore.database.room.find(uniqID: id) {
                            QiscusCore.database.comment.clear(inRoom: room.id)
                        }
                    })
                    completion(nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    completion(QError(message: errorMessage))
                }
            }
        }
    }
    
    func readReceiptStatus(commentId id: String, completion: @escaping (CommentModel?, QError?) -> Void) {
        commentRouter.request(.statusComment(id: id)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let comment = CommentApiResponse.comment(from: response)
                    completion(comment, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, QError(message: errorMessage))
                }
            }
        }
        
    }
}
