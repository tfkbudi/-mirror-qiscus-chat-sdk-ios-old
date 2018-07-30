//
//  NetworkManager.swift
//  QiscusCore
//
//  Created by Qiscus on 18/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

enum NetworkResponse:String {
    case success
    case clientError = "Client Error."
    case serverError = "Server Error."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "Response not JSON or undefined."
}

enum Result<String>{
    case success
    case failure(String)
}

enum NetworkEnvironment : String {
    case production
    case staging
}

// TODO remove public, this class should not be accessed from outside qiscusCore
public class NetworkManager: NSObject {
    static let environment  : NetworkEnvironment = .production
    static let APPID        : String = ""
    static var token        : String = ""
    static var userEmail    : String = ""
    let clientRouter    = Router<APIClient>()
    let roomRouter      = Router<APIRoom>()
    let commentRouter   = Router<APIComment>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        print("response code \(response.statusCode)")
        switch response.statusCode {
        case 200...299: return .success
        case 400...499: return .failure(NetworkResponse.clientError.rawValue)
        case 500...599: return .failure(NetworkResponse.serverError.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }

}
// MARK: Client
extension NetworkManager {
    /// get nonce for JWT authentication
    ///
    /// - Parameter completion: @ecaping on getNonce request done return Optional(QNonce) and Optional(Error message)
    func getNonce(completion: @escaping (QNonce?, String?)->Void) {
        clientRouter.request(.nonce) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<QNonce>.self, from: responseData)
                        completion(apiResponse.results, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    
    /// login
    ///
    /// - Parameters:
    ///   - identityToken: identity token from your server after verify the nonce
    ///   - completion: @escaping when success login retrun Optional(QUser) and Optional(String error message)
    func login(identityToken: String, completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.loginRegisterJWT(identityToken: identityToken)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<UserResults>.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    /// login
    ///
    /// - Parameters:
    ///   - email: username or email identifier
    ///   - password: user password to login to qiscus sdk
    ///   - username: user display name
    ///   - avatarUrl: user avatar url
    ///   - completion: @escaping on 
    func login(email: String, password: String ,username : String? ,avatarUrl : String?, completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.loginRegister(user: email, password: password,username: username,avatarUrl: avatarUrl)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<UserResults>.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    
    /// register device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token for push notification
    ///   - completion: @escaping when success register device token to sdk server returning value bool(success or not) and Optional String(error message)
    func registerDeviceToken(deviceToken: String, completion: @escaping (Bool, String) -> Void) {
        clientRouter.request(.registerDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    completion(true, "Success register device token")
                
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,errorMessage)
                }
            }
        }
    }
    
    /// remove device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token to be remove from server
    ///   - completion: @escaping when success remove device token to sdk server returning value bool(success or not) and Optional String(error message)
    func removeDeviceToken(deviceToken: String, completion: @escaping (Bool, String) -> Void) {
        clientRouter.request(.removeDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    completion(true, "Success register device token")
                    
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,errorMessage)
                }
            }
        }
    }
    
    
    /// get user profile
    ///
    /// - Parameter completion: @escaping when success get user profile, return Optional(QUser) and Optional(String error)
    func getProfile(completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.myProfile) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<UserResults>.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    /// update user profile
    ///
    /// - Parameters:
    ///   - displayName: user new displayname
    ///   - avatarUrl: user new avatar url
    ///   - completion: @escaping when finish updating user profile return update Optional(QUser) and Optional(String error message)
    func updateProfile(displayName: String = "", avatarUrl: String = "", completion: @escaping (QUser?, String?) -> Void) {
        if displayName.isEmpty && avatarUrl.isEmpty {
            return
        }
        
        clientRouter.request(.updateMyProfile(name: displayName, avatarUrl: avatarUrl)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<UserResults>.self, from: responseData)
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
}

// MARK: Room
extension NetworkManager {
    // MARK: todo handle params default value in QiscusCore class
    
    /// get room chat room list
    ///
    /// - Parameters:
    ///   - showParticipant: Bool (true = include participants obj to the room, false = participants obj nil)
    ///   - limit: limit room per page
    ///   - page: page
    ///   - roomType: (single, group, public_channel) by default returning all type
    ///   - showRemoved: Bool (true = include room that has been removed, false = exclude room that has been removed)
    ///   - showEmpty: Bool (true = it will show all rooms that have been created event there are no messages, default is false where only room that have at least one message will be shown)
    ///   - completion: @escaping when success get room list returning Optional([QRoom]), Optional(Meta) contain page, total_room per page, Optional(String error message)
public func getRoomList(showParticipant: Bool = false, limit: Int = 20, page: Int, roomType: RoomType? = nil, showRemoved: Bool = false, showEmpty: Bool = true, completion: @escaping([QRoom]?, Meta?, String?) -> Void) {
        roomRouter.request(.roomList(showParticipants: showParticipant, limit: limit, page: page, roomType: roomType, showRemoved: showRemoved, showEmpty: showEmpty)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomsResults>.self, from: responseData)
                        completion(apiResponse.results.roomsInfo, apiResponse.results.meta, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, nil, errorMessage)
                }
            }
        }
    }
    
    
    /// get room by roomIds | uniqueIds
    ///
    /// - Parameters:
    ///   - roomIds: array of room id
    ///   - roomUniqueIds: array of room unique id
    ///   - showRemoved: Bool (true = include room that has been removed, false = exclude room that has been removed)
    ///   - showEmpty: Bool (true = it will show all rooms that have been created event there are no messages, default is false where only room that have at least one message will be shown)
    ///   - completion: @escaping when success get room list returning Optional([QRoom]), Optional(Meta) contain page, total_room per page, Optional(String error message)
    func getRoomInfo(roomIds: [String]? = [], roomUniqueIds: [String]? = [], showParticipant: Bool = false, showRemoved: Bool = false, completion: @escaping ([QRoom]?, String?) -> Void) {
        roomRouter.request(.roomInfo(roomId: roomIds, roomUniqueId: roomUniqueIds, showParticipants: showParticipant, showRemoved: showRemoved)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomsResults>.self, from: responseData)
                        completion(apiResponse.results.roomsInfo, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    
    /// create group room
    ///
    /// - Parameters:
    ///   - name: room name
    ///   - participants: array of participant's sdk email
    ///   - avatarUrl: room avatar url
    ///   - completion: @escaping when success create room, return created Optional(QRoom), Optional(String error message)
    func createRoom(name: String, participants: [String], avatarUrl: URL? = nil, completion: @escaping (QRoom?, String?) -> Void) {
        roomRouter.request(.createNewRoom(name: name, participants: participants, avatarUrl: avatarUrl)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomCreateGetUpdateResult>.self, from: responseData)
                        completion(apiResponse.results.room, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {

                    }

                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    
    /// update existing room
    ///
    /// - Parameters:
    ///   - roomId: room id
    ///   - roomName: new room name
    ///   - avatarUrl: new room avatar
    ///   - options: new room options
    ///   - completion: @escaping when success update room, return created Optional(QRoom), Optional(String error message)
    func updateRoom(roomId: String, roomName: String?, avatarUrl: URL?, options: String?, completion: @escaping (QRoom?, String?) -> Void) {
        roomRouter.request(.updateRoom(roomId: roomId, roomName: roomName, avatarUrl: avatarUrl, options: options)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomCreateGetUpdateResult>.self, from: responseData)
                        completion(apiResponse.results.room, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    
    /// get room with target sdk email or create if not exist yet
    ///
    /// - Parameters:
    ///   - targetSdkEmail: user's target sdk email
    ///   - avatarUrl: room avatar url
    ///   - distincId: distinc id
    ///   - options: room options (string json)
    ///   - completion: @escaping when success update room, return created Optional(QRoom), Optional([QComment]), Optional(String error message)
    func getOrCreateRoomWithTarget(targetSdkEmail: String, avatarUrl: URL? = nil, distincId: String? = nil, options: String? = nil, completion: @escaping (QRoom?, [QComment]?, String?) -> Void) {
        roomRouter.request(.roomWithTarget(email: [targetSdkEmail], avatarUrl: avatarUrl, distincId: distincId, options: options)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomCreateGetUpdateResult>.self, from: responseData)
                        completion(apiResponse.results.room, apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, nil, errorMessage)
                }
            }
        }
    }
    
    
    /// get room with channel type behavior
    ///
    /// - Parameters:
    ///   - uniqueId: channel uniqueId
    ///   - name: channel name (if not defined it will use unique id as default)
    ///   - avatarUrl: channel avatar
    ///   - options: channel options
    ///   - completion: @escaping when success get or create channel, return Optional(QRoom), Optional([QComment]), Optional(String error)
    func getOrCreateChannel(uniqueId: String, name: String? = nil, avatarUrl: URL? = nil, options: String? = nil, completion: @escaping (QRoom?, [QComment]?, String?) -> Void) {
        roomRouter.request(.channelWithUniqueId(uniqueId: uniqueId, name: name, avatarUrl: avatarUrl, options: options)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomCreateGetUpdateResult>.self, from: responseData)
                        completion(apiResponse.results.room, apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, nil, errorMessage)
                }
            }
        }
    }
    
    
    /// get chat room by id
    ///
    /// - Parameters:
    ///   - roomId: room id
    ///   - completion: @escaping when success get room, return Optional(QRoom), Optional([QComment]), Optional(String error message)
    func getRoomById(roomId: String, completion: @escaping (QRoom?, [QComment]?, String?) -> Void) {
        roomRouter.request(.getRoomById(roomId: roomId)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse<RoomCreateGetUpdateResult>.self, from: responseData)
                        completion(apiResponse.results.room, apiResponse.results.comments, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, nil, errorMessage)
                }
            }
        }
    }
    
    
    /// add participants to a chat room
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - userSdkEmail: array of user's sdk email
    ///   - completion: @escaping when success add participant to room, return added participants Optional([QParticipant]), Optional(String error message)
    func addParticipants(roomId: String, userSdkEmail: [String], completion: @escaping ([QParticipant]?, String?) -> Void) {
        roomRouter.request(.addParticipant(roomId: roomId, emails: userSdkEmail)) { (data, response, error) in
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
                        let apiResponse = try JSONDecoder().decode(ApiResponse<AddParticipantsResult>.self, from: responseData)
                        completion(apiResponse.results.participantsAdded, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    
    func removeParticipants(roomId: String, userSdkEmail: [String], completion: @escaping(Bool, String?) -> Void) {
        roomRouter.request(.removeParticipant(roomId: roomId, emails: userSdkEmail)) { (data, response, error) in
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
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false, errorMessage)
                }
            }
        }
    }
}

// MARK: Comment
extension NetworkManager {
    
    /// load comments on a room or channel
    ///
    /// - Parameters:
    ///   - roomId: room id or unique id
    ///   - lastCommentId: last recieved comment id
    ///   - timestamp: timestamp
    ///   - after: if true returns comments with id >= last_comment_id. if false and last_comment_id is specified, returns last 20 comments with id < last_comment_id. if false and last_comment_id is not specified, returns last 20 comments
    ///   - limit: limit for the result default value is 20, max value is 100
    ///   - completion: @escaping when success load comments, return Optional([QComment]) and Optional(String error message)
    func loadComments(roomId: String, lastCommentId: Int? = nil, timestamp: String? = nil, after: Bool? = nil, limit: Int? = nil, completion: @escaping ([QComment]?, String?) -> Void) {
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
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
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
    ///   - completion: @escaping when success post comment, return Optional(QComment) and Optional(String error message)
    func postComment(roomId: String, type: CommentType = .text, comment: String, payload: String = "", extras: String = "", uniqueTempId: String = "", completion: @escaping(QComment?, String?) -> Void) {
        commentRouter.request(.postComment(topicId: roomId, type: type, comment: comment, payload: payload, extras: extras, uniqueTempId: uniqueTempId)) { (data, response, error) in
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
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    
    /// delete comments
    ///
    /// - Parameters:
    ///   - commentUniqueId: comment unique id or you can use comment.uniqueTempId
    ///   - completion: @escaping when success delete comments, return deleted comment Optional([QComment]) and Optional(String error message)
    func deleteComment(commentUniqueId: [String], completion: @escaping ([QComment]?, String?) -> Void) {
        commentRouter.request(.delete(commentUniqueId: commentUniqueId)) { (data, response, error) in
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
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
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
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false, errorMessage)
                }
            }
        }
    }
    
    func updateCommentStatus(roomId: String, lastCommentReadId: String? = nil, ) {
//        commentRouter.request(.updateStatus(roomId: <#T##Int#>, lastCommentReadId: <#T##Int?#>, lastCommentReceivedId: <#T##Int?#>), completion: <#T##NetworkRouterCompletion##NetworkRouterCompletion##(Data?, URLResponse?, Error?) -> ()#>)
    }
}
