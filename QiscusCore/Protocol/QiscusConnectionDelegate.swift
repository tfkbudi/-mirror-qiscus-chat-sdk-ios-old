//
//  QiscusConnectionDelegate.swift
//  QiscusCore
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusRealtime

public protocol QiscusConnectionDelegate {
    func disconnect(withError err: QError?)
    func connected()
    func connectionState(change state: QiscusRealtimeConnectionState)
}

public protocol QiscusCoreDelegate {
    // MARK: Comment Event in Room
    
    /// new comment is comming
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - comment: new comment object
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel)
    
    /// comment status change
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - comment: new comment where status is change, you can compare from local data
    ///   - status: comment status, exp: deliverd, receipt, or read.
    ///     special case for read, for example we have message 1,2,3,4,5 then you got status change for message 5 it's mean message 1-4 has been read
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus)
    
    // MARK: User Event in Room
    
    /// User Typing Indicator
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - user: object user or participant
    ///   - typing: true if user start typing and false when finish typing. typing time avarange is 5-10s, we assume user typing is finish after that
    func onRoom(_ room: RoomModel, thisParticipant user: ParticipantModel, isTyping typing: Bool)
    
    /// User Online status
    ///
    /// - Parameters:
    ///   - user: object user
    ///   - status: true if user login
    ///   - time: millisecond UTC
    func onChangeUser(_ user: UserModel, onlineStatus status: Bool, whenTime time: Date)
    
    func gotNew(room: RoomModel)
//    func onroom(change: RoomModel, withNew room: RoomModel)
    func remove(room: RoomModel)
}

public protocol QiscusCoreRoomDelegate {
    // MARK: Comment Event in Room
    
    /// new comment is comming
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - comment: new comment object
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel)
    
    /// comment status change
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - comment: new comment where status is change, you can compare from local data
    ///   - status: comment status, exp: deliverd, receipt, or read.
    ///     special case for read, for example we have message 1,2,3,4,5 then you got status change for message 5 it's mean message 1-4 has been read
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus)
    
    // MARK: User Event in Room
    
    /// User Typing Indicator
    ///
    /// - Parameters:
    ///   - room: room where event happen
    ///   - user: object user or participant
    ///   - typing: true if user start typing and false when finish typing. typing time avarange is 5-10s, we assume user typing is finish after that
    func onRoom(_ room: RoomModel, thisParticipant user: ParticipantModel, isTyping typing: Bool)
    
    /// User Online status
    ///
    /// - Parameters:
    ///   - user: object user
    ///   - status: true if user login
    ///   - time: millisecond UTC
    func onChangeUser(_ user: UserModel, onlineStatus status: Bool, whenTime time: Date)
}

public enum CommentStatus {
    case deliver
    case receipt
    case read
    case deleted
}
