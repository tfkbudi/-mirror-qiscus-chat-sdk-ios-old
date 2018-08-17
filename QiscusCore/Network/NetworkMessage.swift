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
    func loadComments(roomId: String, lastCommentId: Int? = nil, timestamp: String? = nil, after: Bool? = nil, limit: Int? = nil, completion: @escaping ([CommentModel]?, String?) -> Void) {
        commentRouter.request(.loadComment(topicId: roomId, lastCommentId: lastCommentId, timestamp: timestamp, after: after, limit: limit)) { (data, response, error) in
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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<CommentsResults>.self, from: responseData)
                        completion(apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
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
    func postComment(roomId: String, type: CommentType = .text, message: String, payload: String? = "", extras: String? = "", uniqueTempId: String = "", completion: @escaping(CommentModel?, String?) -> Void) {
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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<PostCommentResults>.self, from: responseData)
                        completion(apiResponse.results.comment, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
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
    func deleteComment(commentUniqueId: [String], type: DeleteType, completion: @escaping ([CommentModel]?, QError?) -> Void) {
        commentRouter.request(.delete(commentUniqueId: commentUniqueId, type: type)) { (data, response, error) in
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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<CommentsResults>.self, from: responseData)
                        completion(apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
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
    
    
    /// clear all comments on room
    ///
    /// - Parameters:
    ///   - roomUniqueIds: room unique ids
    ///   - completion: @escaping when success clear all comments on a room, return (Bool: true = success, false = failed) and Optional(String error message)
    func clearComments(roomUniqueIds: [String], completion: @escaping(Bool, String?) -> Void) {
        commentRouter.request(.clear(roomChannelIds: roomUniqueIds)) { (data, response, error) in
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard data != nil else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    completion(true, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false, errorMessage)
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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<UnreadModel>.self, from: responseData)
                        completion(apiResponse.results.unread, nil)
                    } catch {
                        print(error)
                        completion(0, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(0, QError(message: errorMessage))
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
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<CommentsResults>.self, from: responseData)
                        completion(apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
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
        commentRouter.request(.clear(roomChannelIds: roomsID)) { (data, response, error) in
            if error != nil {
                completion(QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
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
    
}
