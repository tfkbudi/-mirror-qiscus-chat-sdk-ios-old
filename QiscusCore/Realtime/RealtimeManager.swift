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
    }
    
    func connect(username: String, password: String) {
        guard let client = client else {
            return
        }
        client.connect(username: username, password: password, delegate: self)
        // subcribe user token to get new comment
        if !client.subscribe(endpoint: .comment(token: password)) {
            // subscribeNewComment(token: token)
            self.pendingSubscribeTopic.append(.comment(token: password))
        }
    }
    
    func subscribeRooms(rooms: [RoomModel]) {
        guard let client = client else {
            return
        }
        for room in rooms {
            // subscribe comment deliverd receipt
            if !client.subscribe(endpoint: .delivery(roomID: room.id)){
                QiscusLogger.errorPrint("failed to subscribe event deliver event from room \(room.name)")
            }
            // subscribe comment read
            if !client.subscribe(endpoint: .read(roomID: room.id)) {
                QiscusLogger.errorPrint("failed to subscribe event read from room \(room.name)")
            }
        }
        
    }
    
    func isTyping(_ value: Bool, roomID: String, keepTyping: UInt16? = nil){
        
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
    func didReceiveUserStatus(roomId: String, userEmail: String, timeString: String, timeToken: Double) {
        //
    }
    
    func didReceiveMessageEvent(roomId: String, message: String) {
        //
    }
    
    func didReceiveMessage(data: String) {
        if let json = data.data(using: .utf8) {
            do {
                let comment = try JSONDecoder().decode(CommentModel.self, from: json)
                QiscusEventManager.shared.gotNewMessage(comment: comment)
            }catch {
                QiscusLogger.errorPrint("Failed to parse comment from realtime event")
            }
        }
    }
    
    func didReceiveMessageStatus(roomId: String, commentId: Int, Status: MessageStatus) {
        //
    }
    
    func updateUserTyping(roomId: String, userEmail: String) {
        //
    }
    
    func disconnect(withError err: Error?) {
        QiscusLogger.debugPrint("Qiscus realtime disconnect")
    }
    
    func connected() {
        QiscusLogger.debugPrint("Qiscus realtime connected")
    }
    
    func connectionState(change state: QiscusRealtimeConnectionState) {
        QiscusLogger.debugPrint("Qiscus realtime connection state \(state.rawValue)")
        if state == .connected {
            resumePendingSubscribeTopic()
        }
    }
}

