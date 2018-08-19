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
    public func getRoom(withUser user: String, completion: @escaping (RoomModel?, QError?) -> Void) {
        // call api get_or_create_room_with_target
        QiscusCore.network.getOrCreateRoomWithTarget(targetSdkEmail: user) { (room, comments, error) in
            if let r = room {
                completion(r, nil)
            }else {
                if let e = error {
                    completion(nil, QError.init(message: e))
                }else {
                    completion(nil, QError.init(message: "Unexpectend results"))
                }
            }
        }
    }
    
    /// Get room by channel name
    ///
    /// - Parameters:
    ///   - channel: channel name or channel id
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withChannel channel: String, completion: @escaping (RoomModel?, QError?) -> Void) {
        // call api get_room_by_id
        QiscusCore.network.getRoomInfo(roomIds: nil, roomUniqueIds: [channel], showParticipant: true, showRemoved: false) { (rooms, error) in
            if let room = rooms {
                completion(room.first,nil)
            }else {
                completion(nil,error)
            }
        }
    }
    
    /// Get room with room id
    ///
    /// - Parameters:
    ///   - withID: existing roomID from server or local db.
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withID id: String, completion: @escaping (RoomModel?, QError?) -> Void) {
        // call api get_room_by_id
        QiscusCore.network.getRoomById(roomId: id) { (room, comments, error) in
            if let r = room {
                // save room
                QiscusCore.storage.saveRoom(r)
                completion(r, nil)
            }else {
                if let e = error {
                    completion(nil, QError.init(message: e))
                }else {
                    completion(nil, QError.init(message: "Unexpectend results"))
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
    public func getRooms(withId ids: [String], completion: @escaping ([RoomModel]?, QError?) -> Void) {
        QiscusCore.network.getRoomInfo(roomIds: ids, roomUniqueIds: nil, showParticipant: false, showRemoved: false){ (rooms, error) in
            if let data = rooms {
                // save room
                QiscusCore.storage.saveRooms(data)
            }
            completion(rooms,error)
        }
    }
    
    /// Get Room info
    ///
    /// - Parameters:
    ///   - ids: Unique room id
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func getRooms(withUniqueId ids: [String], completion: @escaping ([RoomModel]?, QError?) -> Void) {
        QiscusCore.network.getRoomInfo(roomIds: nil, roomUniqueIds: ids, showParticipant: false, showRemoved: false){ (rooms, error) in
            if let data = rooms {
                // save room
                QiscusCore.storage.saveRooms(data)
            }
            completion(rooms,error)
        }
    }
    
    /// getAllRoom
    ///
    /// - Parameter completion: Response new Qiscus Room Object and error if exist.
    public func getAllRoom(limit: Int = 20, page: Int = 1,completion: @escaping ([RoomModel]?, QError?) -> Void) {
        // api get room list
        QiscusCore.network.getRoomList(limit: limit, page: page) { (data, meta, error) in
            if let rooms = data {
                // clear local data
//                QiscusCore.storage.clearRoom()
                // save room
                QiscusCore.storage.saveRooms(rooms)
                let roomLocal = QiscusCore.storage.getRooms()
                // subscribe room from local
                QiscusCore.realtime.subscribeRooms(rooms: rooms)
            }
            completion(data,nil)
        }
    }
    
    /// Create new Group room
    ///
    /// - Parameters:
    ///   - withName: Name of group
    ///   - participants: arrau of user id/qiscus email
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func createGroup(withName name: String, participants: [String], avatarUrl url: URL?, completion: @escaping (RoomModel?, String?) -> Void) {
        // call api create_room
        QiscusCore.network.createRoom(name: name, participants: participants, avatarUrl: url, completion: completion)
    }
    
    /// update Group or channel
    ///
    /// - Parameters:
    ///   - id: room id, where room type not single. group and channel is approved
    ///   - name: new room name optional
    ///   - avatarURL: new room Avatar
    ///   - options: String, and JSON string is approved
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func updateRoom(withID id: String, name: String?, avatarURL url: URL?, options: String?, completion: @escaping (RoomModel?, QError?) -> Void) {
        // call api update_room
        QiscusCore.network.updateRoom(roomId: id, roomName: name, avatarUrl: url, options: options, completion: completion)
    }

    /// Update Room
    ///
    /// - Parameters:
    ///   - name: room name
    ///   - avatarUrl: room avatar
    ///   - options: options, string or json string
    ///   - completion: Response new Qiscus Room Object and error if exist.
    public func updateRoom(roomId id: String, name: String?, avatarUrl url: URL?, options: String? = nil, completion: @escaping (RoomModel?, QError?) -> Void) {
        QiscusCore.network.updateRoom(roomId: id, roomName: name, avatarUrl: url, options: options, completion: completion)
    }
    
    /// Add new participant in room(Group)
    ///
    /// - Parameters:
    ///   - userEmails: qiscus user email
    ///   - roomId: room id
    ///   - completion:  Response new Qiscus Participant Object and error if exist.
    public func addParticipant(userEmails emails: [String], roomId: String, completion: @escaping ([MemberModel]?, QError?) -> Void) {
        QiscusCore.network.addParticipants(roomId: roomId, userSdkEmail: emails, completion: completion)
    }
    
    /// remove users from room(Group)
    ///
    /// - Parameters:
    ///   - emails: array qiscus email
    ///   - roomId: room id (group)
    ///   - completion: Response true if success and error if exist
    public func removeParticipant(userEmails emails: [String], roomId: String, completion: @escaping (Bool, QError?) -> Void) {
        QiscusCore.network.removeParticipants(roomId: roomId, userSdkEmail: emails, completion: completion)
    }
    
}
