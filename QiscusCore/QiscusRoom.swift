//
//  QiscusRoom.swift
//  QiscusCore
//
//  Created by Qiscus on 17/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

// MARK: Room Management
extension QiscusCore {
    /// Get or create room with participant
    ///
    /// - Parameters:
    ///   - withUsers: Qiscus user emaial.
    ///   - completion: Qiscus Room Object and error if exist.
    public func getRoom(withUser user: String, onSuccess: @escaping (RoomModel, [CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_or_create_room_with_target
        QiscusCore.network.getOrCreateRoomWithTarget(targetSdkEmail: user, onSuccess: { (room, comments) in
            QiscusCore.database.room.save([room])
            // subscribe room from local
            QiscusCore.realtime.subscribeRooms(rooms: [room])
            var c = [CommentModel]()
            if let _comments = comments {
                // save comments
                QiscusCore.database.comment.save(_comments,publishEvent: false)
                c = _comments
            }
            onSuccess(room,c)
        }) { (error) in
            onError(error)
        }
    }
    
    /// Get or create room by channel name
    /// If room with predefined unique id is not exist then it will create a new one with requester as the only one participant. Otherwise, if room with predefined unique id is already exist, it will return that room and add requester as a participant.
    /// When first call (room is not exist), if requester did not send avatar_url and/or room name it will use default value. But, after the second call (room is exist) and user (requester) send avatar_url and/or room name, it will be updated to that value. Object changed will be true in first call and when avatar_url or room name is updated.
    
    /// - Parameters:
    ///   - channel: channel name or channel id
    ///   - name: channel name
    ///   - avatarUrl: url avatar
    ///   - options: option
    ///   - onSuccess: return object room
    ///   - onError: return object QError
    public func getRoom(withChannel channel: String, name: String? = nil, avatarUrl: URL? = nil, options: String? = nil, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_room_by_id
        QiscusCore.network.getOrCreateChannel(uniqueId: channel, name: name, avatarUrl: avatarUrl, options: options) { (rooms, comments, error) in
            if let room = rooms {
                // save room
                QiscusCore.database.room.save([room])
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: [room])
                var c = [CommentModel]()
                if let _comments = comments {
                    // save comments
                    QiscusCore.database.comment.save(_comments)
                    c = _comments
                }
                onSuccess(room)
            }else {
                onError(QError(message: error ?? "Unexpected error"))
            }
        }
        
        QiscusCore.network.getRoomInfo(roomIds: nil, roomUniqueIds: [channel], showParticipant: true, showRemoved: false) { (rooms, error) in
            if let room = rooms {
                // save room
                QiscusCore.database.room.save(room)
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: room)
                if let first = room.first {
                    onSuccess(first)
                }else {
                    onError(QError(message: "Unexpected error"))
                }
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// Get room with room id
    ///
    /// - Parameters:
    ///   - withID: existing roomID from server or local db.
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withID id: String, onSuccess: @escaping (RoomModel, [CommentModel]) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_room_by_id
        QiscusCore.network.getRoomById(roomId: id) { (room, comments, error) in
            if let r = room {
                // save comments
                var c = [CommentModel]()
                if let _comments = comments {
                    // save comments
                    QiscusCore.database.comment.save(_comments,publishEvent: false)
                    c = _comments
                }
                // save room
                // trick, coz this api object room not provide comment. So we need to path response api.
                r.lastComment = c.first
                QiscusCore.database.room.save([r])
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: [r])
                
                onSuccess(r,c)
            }else {
                if let e = error {
                    onError(QError.init(message: e))
                }else {
                    onError(QError.init(message: "Unexpectend results"))
                }
            }
        }
        // or Load from storage
    }
    
    /// Get Room info
    ///
    /// - Parameters:
    ///   - withId: array of room id
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func getRooms(withId ids: [String], onSuccess: @escaping ([RoomModel]) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.getRoomInfo(roomIds: ids, roomUniqueIds: nil, showParticipant: false, showRemoved: false){ (rooms, error) in
            if let data = rooms {
                // save room
                QiscusCore.database.room.save(data)
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: data)
                onSuccess(data)
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// Get Room info
    ///
    /// - Parameters:
    ///   - ids: Unique room id
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func getRooms(withUniqueId ids: [String], onSuccess: @escaping ([RoomModel]) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.getRoomInfo(roomIds: nil, roomUniqueIds: ids, showParticipant: false, showRemoved: false){ (rooms, error) in
            if let data = rooms {
                // save room
                QiscusCore.database.room.save(data)
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: data)
                onSuccess(data)
            }else {
                onError(error ?? QError(message: "Unexpected error"))
            }
        }
    }
    
    /// getAllRoom
    ///
    /// - Parameter completion: First Completion will return data from local if exis, then return from server with meta data(totalpage,current). Response new Qiscus Room Object and error if exist.
    public func getAllRoom(limit: Int? = nil, page: Int? = nil, showRemoved: Bool = false, showEmpty: Bool = false,onSuccess: @escaping ([RoomModel],Meta?) -> Void, onError: @escaping (QError) -> Void) {
        // api get room lists
      
        QiscusCore.network.getRoomList(limit: limit, page: page, showRemoved: showRemoved, showEmpty: showEmpty) { (data, meta, error) in
            if let rooms = data {
                // save room
                QiscusCore.database.room.save(rooms)
                rooms.forEach({ (_room) in
                    if let _comment = _room.lastComment {
                        // save last comment
                        QiscusCore.database.comment.save([_comment])
                    }
                })

                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: rooms)
                onSuccess(rooms,meta)
            }else {
                onError(QError.init(message: error ?? "Something Wrong"))
            }
        }
    }
    
    /// Create new Group room
    ///
    /// - Parameters:
    ///   - withName: Name of group
    ///   - participants: arrau of user id/qiscus email
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func createGroup(withName name: String, participants: [String], avatarUrl url: URL?, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api create_room
        QiscusCore.network.createRoom(name: name, participants: participants, avatarUrl: url) { (room, error) in
            // save room
            if let data = room {
                QiscusCore.database.room.save([data])
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: [data])
                onSuccess(data)
            }else {
                guard let message = error else {
                    onError(QError.init(message: "Something Wrong"))
                    return
                }
                onError(QError.init(message: message))
            }
        }
    }
    
    /// update Group or channel
    ///
    /// - Parameters:
    ///   - id: room id, where room type not single. group and channel is approved
    ///   - name: new room name optional
    ///   - avatarURL: new room Avatar
    ///   - options: String, and JSON string is approved
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func updateRoom(withID id: String, name: String?, avatarURL url: URL?, options: String?, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api update_room
        QiscusCore.network.updateRoom(roomId: id, roomName: name, avatarUrl: url, options: options) { (room, error) in
            if let data = room {
                QiscusCore.database.room.save([data])
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: [data])
                onSuccess(data)
            }else {
                guard let message = error else {
                    onError(QError.init(message: "Something Wrong"))
                    return
                }
                onError(message)
            }
        }
    }
    
    /// Add new participant in room(Group)
    ///
    /// - Parameters:
    ///   - userEmails: qiscus user email
    ///   - roomId: room id
    ///   - completion:  Response new Qiscus Participant Object and error if exist.
    public func addParticipant(userEmails emails: [String], roomId: String, onSuccess: @escaping ([MemberModel]) -> Void, onError: @escaping (QError) -> Void) {
        
        QiscusCore.network.addParticipants(roomId: roomId, userSdkEmail: emails) { (members, error) in
            if let _members = members {
                // Save participant in local
                QiscusCore.database.member.save(_members, roomID: roomId)
                onSuccess(_members)
            }else{
                if let _error = error {
                    onError(_error)
                }else {
                    onError(QError(message: "Unexpected Error"))
                }
            }
        }
    }
    
    /// remove users from room(Group)
    ///
    /// - Parameters:
    ///   - emails: array qiscus email
    ///   - roomId: room id (group)
    ///   - completion: Response true if success and error if exist
    public func removeParticipant(userEmails emails: [String], roomId: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.removeParticipants(roomId: roomId, userSdkEmail: emails) { (result, error) in
            if result {
                onSuccess(result)
            }else {
                if let _error = error {
                    onError(_error)
                }else {
                    onError(QError(message: "Unexpected Error"))
                }
            }
        }
    }
    
    /// get participant by room id
    ///
    /// - Parameters:
    ///   - roomUniqeId: room id (group)
    ///   - completion: Response new Qiscus Participant Object and error if exist.
    public func getParticipant(roomUniqeId id: String, onSuccess: @escaping ([MemberModel]) -> Void, onError: @escaping (QError) -> Void ) {
        QiscusCore.network.getParticipants(roomUniqeId: id) { (members, error) in
            if let _members = members {
                onSuccess(_members)
            }else{
                if let _error = error {
                    onError(_error)
                }else {
                    onError(QError(message: "Unexpected Error"))
                }
            }
        }
    }
    
    public func leaveRoom(by roomId:String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (QError) -> Void) {
        guard let user = QiscusCore.getProfile() else {
            onError(QError(message: "User not found, please login to continue"))
            return
        }
        guard let room = QiscusCore.database.room.find(id: roomId) else {
            onError(QError(message: "Room not Found"))
            return
        }
        _ = QiscusCore.database.room.delete(room)
        QiscusCore.shared.removeParticipant(userEmails: [user.email], roomId: roomId, onSuccess: onSuccess, onError: onError)
    }
    
    // MARK : Realtime Event
    
    public func subscribeEvent(roomID: String, onEvent: @escaping (RoomEvent) -> Void) {
        return QiscusCore.realtime.subscribeEvent(roomID: roomID, onEvent: onEvent)
    }
    
    public func unsubscribeEvent(roomID: String) {
        QiscusCore.realtime.unsubscribeEvent(roomID: roomID)
    }
    
    public func publishEvent(roomID: String, payload: [String : Any]) -> Bool {
        return QiscusCore.realtime.publishEvent(roomID: roomID, payload: payload)
    }
}
