 //
//  RealtimeManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/08/18.
//

import Foundation
import QiscusRealtime

typealias _roomEvent = (RoomEvent) -> Void
 
class RealtimeManager {
    static var shared : RealtimeManager = RealtimeManager()
    private var client : QiscusRealtime? = nil
    private var pendingSubscribeTopic : [RealtimeSubscribeEndpoint] = [RealtimeSubscribeEndpoint]()
    var state : QiscusRealtimeConnectionState = QiscusRealtimeConnectionState.disconnected
    private var roomEvents : [String : _roomEvent] = [String : _roomEvent]()
    
    func setup(appName: String) {
        // make sure realtime client still single object
        if client != nil { return }
        let bundle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        var deviceID = "00000000"
        if let vendorIdentifier = UIDevice.current.identifierForVendor {
            deviceID = vendorIdentifier.uuidString
        }
        let clientID = "iosMQTT-\(bundle)-\(deviceID)"
        var config = QiscusRealtimeConfig(appName: appName, clientID: clientID)
        if let customServer = ConfigManager.shared.server?.realtimeURL {
            config.hostRealtimeServer = customServer
        }
        if let customPort = ConfigManager.shared.server?.realtimePort {
            config.port = customPort
        }
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
        
        self.resumePendingSubscribeTopic()
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
        
        QiscusLogger.debugPrint("pendingSubscribeTopic count = \(pendingSubscribeTopic.count)")
    }
    
    // MARK : Custom Event
    func subscribeEvent(roomID: String, onEvent: @escaping (RoomEvent) -> Void) {
        guard let c = client else { return }
        // subcribe user token to get new comment
        if !c.subscribe(endpoint: .roomEvent(roomID: roomID)) {
            self.pendingSubscribeTopic.append(.roomEvent(roomID: roomID))
            QiscusLogger.errorPrint("failed to subscribe room Event, then queue in pending")
        }else {
            roomEvents[roomID] = onEvent
        }
    }
    
    func unsubscribeEvent(roomID: String) {
        roomEvents.removeValue(forKey: roomID)
        guard let c = client else {
            return
        }
        // unsubcribe room event
        c.unsubscribe(endpoint: .roomEvent(roomID: roomID))
    }
    
    func publishEvent(roomID: String, payload: [String : Any]) -> Bool {
        guard let c = client else {
            return false
        }
        
        if c.publish(endpoint: .roomEvent(roomID: roomID, payload: payload.dict2json())) {
            return true //
        }else {
            return false
        }
    }
    
    // util
    func toDictionary(text : String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("error parsing \(error.localizedDescription)")
            }
        }
        return nil
    }
}

 extension RealtimeManager: QiscusRealtimeDelegate {
    func didReceiveRoomEvent(roomID: String, data: String) {
        guard let payload = toDictionary(text: data) else { return }
        guard let postEvent = roomEvents[roomID] else { return }
        let event = RoomEvent(sender: payload["sender"] as? String ?? "", data: payload["data"] as? [String : Any] ?? ["":""])
        postEvent(event)
    }
    
    func didReceiveUser(userEmail: String, isOnline: Bool, timestamp: String) {
        QiscusEventManager.shared.gotEvent(email: userEmail, isOnline: isOnline, timestamp: timestamp)
    }

    func didReceiveMessageStatus(roomId: String, commentId: String, commentUniqueId: String, Status: MessageStatus) {
        guard let _comment = QiscusCore.database.comment.find(uniqueId: commentUniqueId) else { return }
        var _status : CommentStatus? = nil
        switch Status {
        case .deleted:
            _status  = .deleted
            // delete from local
            _comment.status = .deleted
            _comment.isDeleted  = true
            _ = QiscusCore.database.comment.delete(_comment)
            break
        case .delivered:
            _status  = .delivered
            break
        case .read:
            _status  = .read
            break
        }
        // check convert status
        guard let status = _status else { return }
        if status == .deleted { return }
        if let room = QiscusCore.database.room.find(id: roomId) {
            // very tricky, need to review v3, calculating comment status in backend for group rooms
            if let comments = QiscusCore.database.comment.find(roomId: roomId) {
                guard let user = QiscusCore.getProfile() else { return }
                var mycomments = comments.filter({ $0.userEmail == user.email }) // filter my comment
                mycomments = mycomments.filter({ $0.status.intValue < status.intValue }) // filter status < new status
                mycomments = mycomments.filter({ $0.date <= _comment.date })
                // call api
                guard let lastMyComment = mycomments.last else { return }
                
                if room.type == .single {
                    // compare current status
                    if lastMyComment.status.intValue < status.intValue {
                        // update all my comment status
                        mycomments.forEach { (c) in
                            // check lastStatus and compare
                            if c.status.intValue < status.intValue {
                                let new = c
                                // update comment
                                new.status = status
                                QiscusCore.database.comment.save([new])
                                QiscusCore.eventManager.gotMessageStatus(comment: new) // patch hard update
                            }
                            
                        }
                    }
                }else if room.type == .group {
                    QiscusCore.shared.readReceiptStatus(commentId: lastMyComment.id, onSuccess: { (commentInfo) in
                        print(commentInfo.deliveredUser.first?.username)
                        let result = commentInfo.comment
                        // compare current status
                        if lastMyComment.status.intValue < result.status.intValue {
                            // update all my comment status
                            for c in mycomments {
                                // check lastStatus and compare
                                if c.status.intValue != result.status.intValue {
                                    // update comment
                                    c.status = result.status
                                    QiscusCore.database.comment.save([c])
                                }
                            }
                            mycomments.forEach { (c) in
                                // check lastStatus and compare
                                if c.status.intValue < status.intValue {
                                    let new = c
                                    // update comment
                                    new.status = status
                                    QiscusCore.database.comment.save([new])
                                    QiscusCore.eventManager.gotMessageStatus(comment: new) // patch hard update
                                }
                            }
                        }
                    }) { (error) in
                        //
                    }
                }else {
                    // ignore for channel
                }
            }
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

