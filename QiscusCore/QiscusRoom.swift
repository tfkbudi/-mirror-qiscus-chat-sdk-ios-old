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
    public func getRoom(withUsers users: [String], completion: @escaping (String, Error) -> Void) {
        // call api get_or_create_room_with_target
        QiscusCore.network.createRoom(name: <#T##String#>, participants: <#T##[String]#>, avatarUrl: <#T##URL?#>, completion: <#T##(QRoom?, String?) -> Void#>)
    }
    
    /// Get room with room id
    ///
    /// - Parameters:
    ///   - withID: existing roomID from server or local db.
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withID id: String, completion: @escaping (String, Error) -> Void) {
        // call api get_room_by_id
        // or Load from storage
    }
    
    /// Get room by channel name
    ///
    /// - Parameters:
    ///   - channel: channel name or channel id
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func getRoom(withChannel channel: String, completion: @escaping (String, Error) -> Void) {
        // call api get_room_by_id
    }
    
    /// Create new Group room
    ///
    /// - Parameters:
    ///   - withName: Name of group
    ///   - participants: arrau of user id/qiscus email
    ///   - completion: Response Qiscus Room Object and error if exist.
    public func createGroup(withName name: String, participants: [String], avatarUrl url: URL?, completion: @escaping (QRoom?, String?) -> Void) {
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
    public func updateRoom(withID id: String, name: String?, avatarURL: URL?, options: String?, completion: @escaping (QRoom?, String?) -> Void) {
        // call api update_room
    }
}
