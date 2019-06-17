//
//  NetworkRoom.swift
//  QiscusCore
//
//  Created by Qiscus on 14/08/18.
//

// MARK: Room
extension NetworkManager {
    /// get room chat room list
    ///
    /// - Parameters:
    ///   - showParticipant: Bool (true = include participants obj to the room, false = participants obj nil)
    ///   - limit: limit room per page
    ///   - page: page
    ///   - roomType: (single, group, public_channel) by default returning all type
    ///   - showRemoved: Bool (true = include room that has been removed, false = exclude room that has been removed)
    ///   - showEmpty: Bool (true = it will show all rooms that have been created event there are no messages, default is false where only room that have at least one message will be shown)
    ///   - completion: @escaping when success get room list returning Optional([RoomModel]), Optional(Meta) contain page, total_room per page, Optional(String error message)
    func getRoomList(showParticipant: Bool = true, limit: Int? = nil, page: Int? = nil, roomType: RoomType? = nil, showRemoved: Bool = false, showEmpty: Bool = false, completion: @escaping([RoomModel]?, Meta?, String?) -> Void) {
        roomRouter.request(.roomList(showParticipants: showParticipant, limit: limit, page: page, roomType: roomType, showRemoved: showRemoved, showEmpty: showEmpty)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, error?.localizedDescription ?? "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let rooms       = RoomApiResponse.rooms(from: response)
                    let meta        = RoomApiResponse.meta(from: response)
                    completion(rooms, meta, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
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
    ///   - completion: @escaping when success get room list returning Optional([RoomModel]), Optional(Meta) contain page, total_room per page, Optional(String error message)
    func getRoomInfo(roomIds: [String]? = [], roomUniqueIds: [String]? = [], showParticipant: Bool = false, showRemoved: Bool = false, completion: @escaping ([RoomModel]?, QError?) -> Void) {
        roomRouter.request(.roomInfo(roomId: roomIds, roomUniqueId: roomUniqueIds, showParticipants: showParticipant, showRemoved: showRemoved)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let rooms       = RoomApiResponse.rooms(from: response)
                    completion(rooms, nil)
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
    
    
    /// create group room
    ///
    /// - Parameters:
    ///   - name: room name
    ///   - participants: array of participant's sdk email
    ///   - avatarUrl: room avatar url
    ///   - completion: @escaping when success create room, return created Optional(RoomModel), Optional(String error message)
    func createRoom(name: String, participants: [String], avatarUrl: URL? = nil, completion: @escaping (RoomModel?, String?) -> Void) {
        roomRouter.request(.createNewRoom(name: name, participants: participants, avatarUrl: avatarUrl)) { (data, response, error) in
            if error != nil {
                completion(nil, error?.localizedDescription ?? "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let rooms       = RoomApiResponse.room(from: response)
                    completion(rooms, nil)
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
    
    
    /// update existing room
    ///
    /// - Parameters:
    ///   - roomId: room id
    ///   - roomName: new room name
    ///   - avatarUrl: new room avatar
    ///   - options: new room options
    ///   - completion: @escaping when success update room, return created Optional(RoomModel), Optional(String error message)
    func updateRoom(roomId: String, roomName: String?, avatarUrl: URL?, options: String?, completion: @escaping (RoomModel?, QError?) -> Void) {
        roomRouter.request(.updateRoom(roomId: roomId, roomName: roomName, avatarUrl: avatarUrl, options: options)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let room        = RoomApiResponse.room(from: response)
                    completion(room, nil)
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
    
    
    /// get room with target sdk email or create if not exist yet
    ///
    /// - Parameters:
    ///   - targetSdkEmail: user's target sdk email
    ///   - avatarUrl: room avatar url
    ///   - distincId: distinc id
    ///   - options: room options (string json)
    ///   - completion: @escaping when success update room, return created Optional(RoomModel), Optional([CommentModel]), Optional(String error message)
    func getOrCreateRoomWithTarget(targetSdkEmail: String, avatarUrl: URL? = nil, distincId: String? = nil, options: String? = nil, onSuccess: @escaping (RoomModel,[CommentModel]?) -> Void, onError: @escaping (QError) -> Void) {
        roomRouter.request(.roomWithTarget(email: [targetSdkEmail], avatarUrl: avatarUrl, distincId: distincId, options: options)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let room        = RoomApiResponse.room(from: response)
                    let comments    = CommentApiResponse.comments(from: response)
                    onSuccess(room,comments)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message: errorMessage))
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
    ///   - completion: @escaping when success get or create channel, return Optional(RoomModel), Optional([CommentModel]), Optional(String error)
    func getOrCreateChannel(uniqueId: String, name: String? = nil, avatarUrl: URL? = nil, options: String? = nil, completion: @escaping (RoomModel?, [CommentModel]?, String?) -> Void) {
        roomRouter.request(.channelWithUniqueId(uniqueId: uniqueId, name: name, avatarUrl: avatarUrl, options: options)) { (data, response, error) in
            if error != nil {
                completion(nil, nil, error?.localizedDescription ?? "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let room        = RoomApiResponse.room(from: response)
                    let comments    = CommentApiResponse.comments(from: response)
                    completion(room, comments, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
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
    ///   - completion: @escaping when success get room, return Optional(RoomModel), Optional([CommentModel]), Optional(String error message)
    func getRoomById(roomId: String, onSuccess: @escaping (RoomModel, [CommentModel]?) -> Void, onError: @escaping (QError) -> Void) {
        roomRouter.request(.getRoomById(roomId: roomId)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let room        = RoomApiResponse.room(from: response)
                    let comments    = CommentApiResponse.comments(from: response)
                    onSuccess(room,comments)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message: errorMessage))
                }
            }
        }
    }
    
    /// get participants to a chat room
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - userSdkEmail: array of user's sdk email
    ///   - offset : default is 0
    ///   - sorting : default is asc
    ///   - completion: @escaping when success add participant to room, return added participants Optional([MemberModel]), Optional(String error message)
    func getParticipants(roomUniqeId id: String, offset: Int? = nil, sorting: SortType? = nil, completion: @escaping ([MemberModel]?, QError?) -> Void) {
        roomRouter.request(.getParticipant(roomId: id, offset: offset, sorting: sorting)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let members     = RoomApiResponse.participants(from: response)
                    completion(members, nil)
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
    
    /// add participants to a chat room
    ///
    /// - Parameters:
    ///   - roomId: chat room id
    ///   - userSdkEmail: array of user's sdk email
    ///   - completion: @escaping when success add participant to room, return added participants Optional([MemberModel]), Optional(String error message)
    func addParticipants(roomId: String, userSdkEmail: [String], completion: @escaping ([MemberModel]?, QError?) -> Void) {
        roomRouter.request(.addParticipant(roomId: roomId, emails: userSdkEmail)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    
                    let response    = ApiResponse.decode(from: responseData)
                    let members     = RoomApiResponse.addParticipants(from: response)
                    completion(members, nil)
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
    
    /// Remove
    ///
    /// - Parameters:
    ///   - roomId: room id where you want to remove member
    ///   - userSdkEmail: array if qiscus email
    ///   - completion: Response true if success and false if error, and error message if exist
    func removeParticipants(roomId: String, userSdkEmail: [String], completion: @escaping(Bool, QError?) -> Void) {
        roomRouter.request(.removeParticipant(roomId: roomId, emails: userSdkEmail)) { (data, response, error) in
            if error != nil {
                completion(false, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard data != nil else {
                        completion(false, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    
                    completion(true, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false, QError(message: errorMessage))
                }
            }
        }
    }
}
