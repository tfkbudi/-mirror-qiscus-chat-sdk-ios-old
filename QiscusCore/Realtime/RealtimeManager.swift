//
//  RealtimeManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/08/18.
//

import Foundation
import QiscusRealtime

class RealtimeManager {
//    private var
    private var client : QiscusRealtime

    init(appName: String) {
        let bundle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        var deviceID = "000"
        if let vendorIdentifier = UIDevice.current.identifierForVendor {
            deviceID = vendorIdentifier.uuidString
        }
        let clientID = "iosMQTT-\(bundle)-\(deviceID)"
        let config = QiscusRealtimeConfig(appName: appName, clientID: clientID)
        client = QiscusRealtime.init(withConfig: config)
        client.enableDebugPrint = true
    }
    
    func connect(username: String, password: String) {
        client.connect(username: username, password: password, delegate: self)
        // subcribe user token to get new comment
        //subscribeComment(token: password)
        client.subscribe(endpoint: .comment(token: password))
    }
    
    func subscribeRooms(rooms: [RoomModel]) {
        for room in rooms {
            // subscribe comment deliverd receipt
            client.subscribe(endpoint: .delivery(roomID: room.id))
            // subscribe comment read
            client.subscribe(endpoint: .read(roomID: room.id))
        }
        
    }
    
    func isTyping(_ value: Bool, roomID: String, keepTyping: UInt16? = nil){
        
    }
    
}

extension RealtimeManager: QiscusRealtimeDelegate {
    func didReceiveUserStatus(roomId: String, userEmail: String, timeString: String, timeToken: Double) {
        //
    }
    
    func didReceiveMessageEvent(roomId: String, message: String) {
        //
    }
    
    func didReceiveMessageComment(roomId: String, message: String) {
        //
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
    }
}

