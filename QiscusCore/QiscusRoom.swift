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
    public func getRoom(withUser user: String, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_or_create_room_with_target
        QiscusCore.network.getOrCreateRoomWithTarget(targetSdkEmail: user, onSuccess: { (room, comments) in
            QiscusCore.database.room.save([room])
            // subscribe room from local
            QiscusCore.realtime.subscribeRooms(rooms: [room])
            if let _comments = comments {
                // save comments
                QiscusCore.database.comment.save(_comments)
            }
            onSuccess(room)
        }) { (error) in
            onError(error)
        }
    }
    
    /// Get room by channel name
    ///
    /// - Parameters:
    ///   - channel: channel name or channel id
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withChannel channel: String, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_room_by_id
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
    public func getRoom(withID id: String, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
        // call api get_room_by_id
        QiscusCore.network.getRoomById(roomId: id) { (room, comments, error) in
            if let r = room {
                // save room
                QiscusCore.database.room.save([r])
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: [r])
                onSuccess(r)
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
    public func getAllRoom(limit: Int? = nil, page: Int? = nil,onSuccess: @escaping ([RoomModel],Meta?) -> Void, onError: @escaping (QError) -> Void) {
        // api get room list
        QiscusCore.network.getRoomList(limit: limit, page: page) { (data, meta, error) in
            if let rooms = data {
                // save room
                QiscusCore.database.room.save(rooms)
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

    /// Update Room
    ///
    /// - Parameters:
    ///   - name: room name
    ///   - avatarUrl: room avatar
    ///   - options: options, string or json string
    ///   - completion: Response new Qiscus Room Object and error if exist.
//    public func updateRoom(roomId id: String, name: String?, avatarUrl url: URL?, options: String? = nil, onSuccess: @escaping (RoomModel) -> Void, onError: @escaping (QError) -> Void) {
//        QiscusCore.network.updateRoom(roomId: id, roomName: name, avatarUrl: url, options: options, completion: completion)
//    }
    
    /// Add new participant in room(Group)
    ///
    /// - Parameters:
    ///   - userEmails: qiscus user email
    ///   - roomId: room id
    ///   - completion:  Response new Qiscus Participant Object and error if exist.
    public func addParticipant(userEmails emails: [String], roomId: String, onSuccess: @escaping ([MemberModel]) -> Void, onError: @escaping (QError) -> Void) {
        QiscusCore.network.addParticipants(roomId: roomId, userSdkEmail: emails) { (members, error) in
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
    ///   - roomId: room id (group)
    ///   - completion: Response new Qiscus Participant Object and error if exist.
    public func getParticipant(roomId: String, onSuccess: @escaping ([MemberModel]) -> Void, onError: @escaping (QError) -> Void ) {
        QiscusCore.network.getParticipants(roomId: roomId) { (members, error) in
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
}
