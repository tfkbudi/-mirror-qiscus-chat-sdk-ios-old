 //
//  RealtimeManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/08/18.
//

import Foundation
import QiscusRealtime

class RealtimeManager {
    static var shared : RealtimeManager = RealtimeManager()
    private var client : QiscusRealtime? = nil
    private var pendingSubscribeTopic : [RealtimeSubscribeEndpoint] = [RealtimeSubscribeEndpoint]()
    var state : QiscusRealtimeConnectionState = QiscusRealtimeConnectionState.disconnected
    
    func setup(appName: String) {
        // make sure realtime client still single object
        if client != nil { return }
        let bundle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        var deviceID = "00000000"
        if let vendorIdentifier = UIDevice.current.identifierForVendor {
            deviceID = vendorIdentifier.uuidString
        }
        let clientID = "iosMQTT-\(bundle)-\(deviceID)"
        let config = QiscusRealtimeConfig(appName: appName, clientID: clientID)
        client = QiscusRealtime.init(withConfig: config)
        QiscusRealtime.enableDebugPrint = QiscusCore.enableDebugPrint
    }
    
    func disconnect() {
        guard let c = client else {
            return
        }
        c.disconnect()
        self.pendingSubscribeTopic.removeAll()
    }
    
    func connect(username: String, password: String) {
        guard let c = client else {
            return
        }
        c.connect(username: username, password: password, delegate: self)
        // subcribe user token to get new comment
        if !c.subscribe(endpoint: .comment(token: password)) {
            self.pendingSubscribeTopic.append(.comment(token: password))
            QiscusLogger.errorPrint("failed to subscribe event comment or new comment, then queue in pending")
        }
        // subcribe user notification
        if !c.subscribe(endpoint: .notification(token: password)) {
            self.pendingSubscribeTopic.append(.notification(token: password))
            QiscusLogger.errorPrint("failed to subscribe event comment or new comment, then queue in pending")
        }
    }
    
    
    /// Subscribe comment(deliverd and read), typing by member in the room, and online status
    ///
    /// - Parameter rooms: array of rooms
    // MARK: TODO optimize, check already subscribe?
    func subscribeRooms(rooms: [RoomModel]) {
        guard let c = client else {
            return
        }
        for room in rooms {
            // subscribe comment deliverd receipt
            if !c.subscribe(endpoint: .delivery(roomID: room.id)){
                self.pendingSubscribeTopic.append(.delivery(roomID: room.id))
                QiscusLogger.errorPrint("failed to subscribe event deliver event from room \(room.name), then queue in pending")
            }
            // subscribe comment read
            if !c.subscribe(endpoint: .read(roomID: room.id)) {
                self.pendingSubscribeTopic.append(.read(roomID: room.id))
                QiscusLogger.errorPrint("failed to subscribe event read from room \(room.name), then queue in pending")
            }
            if !c.subscribe(endpoint: .typing(roomID: room.id)) {
                self.pendingSubscribeTopic.append(.typing(roomID: room.id))
                QiscusLogger.errorPrint("failed to subscribe event typing from room \(room.name), then queue in pending")
            }
            guard let participants = room.participants else { return }
            for u in participants {
                if !c.subscribe(endpoint: .onlineStatus(user: u.email)) {
                    self.pendingSubscribeTopic.append(.onlineStatus(user: u.email))
                    QiscusLogger.errorPrint("failed to subscribe online status user \(u.email), then queue in pending")
                }
            }
        }
    }
    
    func isTyping(_ value: Bool, roomID: String){
        guard let c = client else {
            return
        }
        if !c.publish(endpoint: .isTyping(value: value, roomID: roomID)) {
            QiscusLogger.errorPrint("failed to send typing to roomID \(roomID)")
        }
    }
    
    func isOnline(_ value: Bool) {
        guard let c = client else {
            return
        }
        if !c.publish(endpoint: .onlineStatus(value: value)) {
            QiscusLogger.errorPrint("failed to send Online status")
        }
    }
    
    func resumePendingSubscribeTopic() {
        guard let client = client else {
            return
        }
        QiscusLogger.debugPrint("Resume pending subscribe")
        // resume pending subscribe
        if !pendingSubscribeTopic.isEmpty {
            for (i,t) in pendingSubscribeTopic.enumerated().reversed() {
                // check if success subscribe
                if client.subscribe(endpoint: t) {
                    // remove from pending list
                   self.pendingSubscribeTopic.remove(at: i)
                }
            }
        }
    }
    
}

extension RealtimeManager: QiscusRealtimeDelegate {
    func didReceiveUser(userEmail: String, isOnline: Bool, timestamp: String) {
        QiscusEventManager.shared.gotEvent(email: userEmail, isOnline: isOnline, timestamp: timestamp)
    }

    
    func didReceiveMessageStatus(roomId: String, commentId: String, commentUniqueId: String, Status: MessageStatus) {
        switch Status {
        case .deleted:
            // delete from local
            _ = QiscusCore.database.comment.delete(uniqId: commentUniqueId)
            QiscusEventManager.shared.gotMessageStatus(roomID: roomId, commentUniqueID: commentUniqueId, status: .deleted)
            break
        case .delivered:
            QiscusEventManager.shared.gotMessageStatus(roomID: roomId, commentUniqueID: commentUniqueId, status: .delivered)
            break
        case .read:
            QiscusEventManager.shared.gotMessageStatus(roomID: roomId, commentUniqueID: commentUniqueId, status: .read)
            break
        }
    }
    
    func didReceiveMessage(data: String) {
        let json = ApiResponse.decode(string: data)
        let comment = CommentModel(json: json)
        QiscusCore.database.comment.save([comment])
    }
    
    func didReceiveUser(typing: Bool, roomId: String, userEmail: String) {
        QiscusEventManager.shared.gotTyping(roomID: roomId, user: userEmail, value: typing)
    }
    
    func connectionState(change state: QiscusRealtimeConnectionState) {
        QiscusLogger.debugPrint("Qiscus realtime connection state \(state.rawValue)")
        self.state = state
        if let state : QiscusConnectionState = QiscusConnectionState(rawValue: state.rawValue) {
            QiscusEventManager.shared.connectionDelegate?.connectionState(change: state)
        }
        
        switch state {
        case .connected:
            resumePendingSubscribeTopic()
            QiscusLogger.debugPrint("Qiscus realtime connected")
            break
        case .disconnected:
            QiscusCore.heartBeat?.resume()
            break
        default:
            break
        }
    }
}

