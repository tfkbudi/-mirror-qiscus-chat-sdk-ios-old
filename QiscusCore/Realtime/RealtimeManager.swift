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
        print("debug \(QiscusCore.enableDebugPrint) : \(QiscusRealtime.enableDebugPrint)")
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
            // subscribeNewComment(token: token)
            self.pendingSubscribeTopic.append(.comment(token: password))
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
                QiscusLogger.errorPrint("failed to subscribe event deliver event from room \(room.name)")
            }
            // subscribe comment read
            if !c.subscribe(endpoint: .read(roomID: room.id)) {
                QiscusLogger.errorPrint("failed to subscribe event read from room \(room.name)")
            }
            if !c.subscribe(endpoint: .typing(roomID: room.id)) {
                QiscusLogger.errorPrint("failed to subscribe event typing from room \(room.name)")
            }
            guard let participants = room.participants else { return }
            for u in participants {
                if !c.subscribe(endpoint: .onlineStatus(user: u.email)) {
                    QiscusLogger.errorPrint("failed to subscribe online status user \(u.email)")
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
        //
    }
    
    func didReceiveMessage(data: String) {
        let json = ApiResponse.decode(string: data)
        let comment = CommentModel(json: json)
        QiscusEventManager.shared.gotNewMessage(comment: comment)
    }
    
    func didReceiveUser(typing: Bool, roomId: String, userEmail: String) {
        QiscusEventManager.shared.gotTyping(roomID: roomId, user: userEmail, value: typing)
    }
    
    func connectionState(change state: QiscusRealtimeConnectionState) {
        QiscusLogger.debugPrint("Qiscus realtime connection state \(state.rawValue)")
        if state == .connected {
            resumePendingSubscribeTopic()
            QiscusLogger.debugPrint("Qiscus realtime connected")
        }
    }
}

