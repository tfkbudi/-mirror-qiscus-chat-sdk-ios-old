 //
//  RealtimeManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/08/18.
//

import Foundation
import QiscusRealtime

typealias _roomEvent = (RoomEvent) -> Void
typealias _roomTyping = (RoomTyping) -> Void
 
class RealtimeManager {
    static var shared : RealtimeManager = RealtimeManager()
    private var client : QiscusRealtime? = nil
    private var pendingSubscribeTopic : [RealtimeSubscribeEndpoint] = [RealtimeSubscribeEndpoint]()
    var state : QiscusRealtimeConnectionState = QiscusRealtimeConnectionState.disconnected
    private var roomEvents : [String : _roomEvent] = [String : _roomEvent]()
    
    private var roomTypings : [String : _roomTyping] = [String : _roomTyping]()
    
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
        self.pendingSubscribeTopic.append(.comment(token: password))
        self.pendingSubscribeTopic.append(.notification(token: password))
        
        c.connect(username: username, password: password, delegate: self)
        
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
            if room.type == .channel{
                if let appId = ConfigManager.shared.appID {
                    if !c.subscribe(endpoint: .roomChannel(AppId: appId, roomUniqueId: room.uniqueId)){
                         self.pendingSubscribeTopic.append(.roomChannel(AppId: appId, roomUniqueId: room.uniqueId))
                         QiscusLogger.errorPrint("failed to subscribe room channel \(room.name), then queue in pending")
                    }
                }
            }else{
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
        
        self.resumePendingSubscribeTopic()
    }
    
    /// Subscribe comment(deliverd and read), typing by member in the room, and online status
    ///
    /// - Parameter rooms: array of rooms
    // MARK: TODO optimize, check already subscribe?
    func subscribeRoomsWithoutOnlineStatus(rooms: [RoomModel]) {
        guard let c = client else {
            return
        }
        for room in rooms {
            if room.type == .channel{
                if let appId = ConfigManager.shared.appID {
                    if !c.subscribe(endpoint: .roomChannel(AppId: appId, roomUniqueId: room.uniqueId)){
                        self.pendingSubscribeTopic.append(.roomChannel(AppId: appId, roomUniqueId: room.uniqueId))
                        QiscusLogger.errorPrint("failed to subscribe room channel \(room.name), then queue in pending")
                    }
                }
            }else{
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
            }
        }
        
        self.resumePendingSubscribeTopic()
    }
    
    func unsubscribeRooms(rooms: [RoomModel]) {
        guard let c = client else {
            return
        }
        
        for room in rooms {
            if room.type == .channel {
                if let appId = ConfigManager.shared.appID {
                    c.unsubscribe(endpoint: .roomChannel(AppId: appId, roomUniqueId: room.uniqueId))
                }
            }else{
                // unsubcribe room event
                c.unsubscribe(endpoint: .delivery(roomID: room.id))
                c.unsubscribe(endpoint: .read(roomID: room.id))
                c.unsubscribe(endpoint: .typing(roomID: room.id))
                guard let participants = room.participants else { return }
                for u in participants {
                    c.unsubscribe(endpoint: .onlineStatus(user: u.email))
                }
            }
        }
        
    }
    
    func unsubscribeRoomsWithoutOnlineStatus(rooms: [RoomModel]) {
        guard let c = client else {
            return
        }
        
        for room in rooms {
            if room.type == .channel {
                if let appId = ConfigManager.shared.appID {
                    c.unsubscribe(endpoint: .roomChannel(AppId: appId, roomUniqueId: room.uniqueId))
                }
            }else{
                // unsubcribe room event
                c.unsubscribe(endpoint: .delivery(roomID: room.id))
                c.unsubscribe(endpoint: .read(roomID: room.id))
                c.unsubscribe(endpoint: .typing(roomID: room.id))
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
        
        QiscusLogger.debugPrint("pendingSubscribeTopic count = \(pendingSubscribeTopic.count)")
    }
    
    // MARK : Typing event
    func subscribeTyping(roomID: String, onTyping: @escaping (RoomTyping) -> Void) {
        guard let c = client else { return }
        
        if c.isConnect{
            if !c.subscribe(endpoint: .typing(roomID: roomID)) {
                self.pendingSubscribeTopic.append(.typing(roomID: roomID))
                QiscusLogger.errorPrint("failed to subscribe event typing from room \(roomID), then queue in pending")
            }else{
                self.roomTypings[roomID] = onTyping
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.subscribeTyping(roomID: roomID) { (roomTyping) in
                    self.roomTypings[roomID] = onTyping
                }
            }
            
        }
    }
    
    func unsubscribeTyping(roomID: String) {
        roomTypings.removeValue(forKey: roomID)
        guard let c = client else {
            return
        }
        // unsubcribe room event
        c.unsubscribe(endpoint: .typing(roomID: roomID))
    }
    
    // MARK : Custom Event
    func subscribeEvent(roomID: String, onEvent: @escaping (RoomEvent) -> Void) {
        guard let c = client else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.subscribeEvent(roomID: roomID, onEvent: onEvent)
                return
            }
            return
        }
        
        if c.isConnect{
            // subcribe user token to get new comment
            if !c.subscribe(endpoint: .roomEvent(roomID: roomID)) {
                self.pendingSubscribeTopic.append(.roomEvent(roomID: roomID))
                QiscusLogger.errorPrint("failed to subscribe room Event, then queue in pending")
            }else {
                self.roomEvents[roomID] = onEvent
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.subscribeEvent(roomID: roomID, onEvent: { (roomEvent) in
                    self.roomEvents[roomID] = onEvent
                })
            }
        }
    }
    
    func unsubscribeEvent(roomID: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.roomEvents.count == 0 {
                return
            }
            
            guard let c = self.client else {
                return
            }
            
            if self.roomEvents.removeValue(forKey: roomID) != nil{
                // unsubcribe room event
                c.unsubscribe(endpoint: .roomEvent(roomID: roomID))
            }
        }
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

    func didReceiveMessageStatus(roomId: String, commentId: String, commentUniqueId: String, Status: MessageStatus, userEmail: String) {
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
                    guard let participants = room.participants else {
                        QiscusCore.network.getRoomById(roomId: room.id, onSuccess: { (room, comments) in
                            // save room
                            if let comments = comments {
                                room.lastComment = comments.first
                            }
                            
                            QiscusCore.database.room.save([room])
                            
                            // save comments
                            var c = [CommentModel]()
                            if let _comments = comments {
                                // save comments
                                QiscusCore.database.comment.save(_comments)
                                c = _comments
                            }
                            
                            return
                        }) { (error) in
                            return
                        }
                        
                        return
                    }
                    
                    for participant in participants{
                        if(userEmail.lowercased() == participant.email.lowercased()){
                            switch Status {
                            case .delivered:
                                if let commentID = Int(commentId){
                                    if(commentID > participant.lastCommentReceivedId){
                                        participant.lastCommentReceivedId = commentID
                                        QiscusCore.database.member.save([participant], roomID: roomId)
                                    }
                                }
                                break
                            case .read:
                                if let commentID = Int(commentId){
                                    if(commentID > participant.lastCommentReadId){
                                        participant.lastCommentReadId = commentID
                                        participant.lastCommentReceivedId = commentID
                                        QiscusCore.database.member.save([participant], roomID: roomId)
                                    }
                                }
                                break
                            case .deleted:
                                break
                            }
                        }else if participant.email.lowercased() == user.email.lowercased(){
                            if let commentID = Int(commentId){
                                if(commentID > participant.lastCommentReadId){
                                    participant.lastCommentReadId = commentID
                                    participant.lastCommentReceivedId = commentID
                                    QiscusCore.database.member.save([participant], roomID: roomId)
                                }
                            }
                        }
                    }
                    
                    var readUser = [MemberModel]()
                    var deliveredUser = [MemberModel]()
                    var sentUser = [MemberModel]()
                    
                    if let room = QiscusCore.database.room.find(id: roomId){
                        for participant in room.participants!{
                            if let commentID = Int(commentId){
                                if participant.lastCommentReadId == commentID{
                                    readUser.append(participant)
                                }else if (participant.lastCommentReceivedId == commentID){
                                    deliveredUser.append(participant)
                                }else{
                                    sentUser.append(participant)
                                }
                            }
                            
                        }
                    
                        if(readUser.count == room.participants?.count){
                            if lastMyComment.status.intValue < status.intValue {
                                // update all my comment status
                                mycomments.forEach { (c) in
                                    // check lastStatus and compare
                                    if c.status.intValue < status.intValue {
                                        let new = c
                                        // update comment
                                        new.status = .read
                                        QiscusCore.database.comment.save([new])
                                        QiscusCore.eventManager.gotMessageStatus(comment: new)
                                    }
                                    
                                }
                            }

                        }else{
                            if lastMyComment.status.intValue < status.intValue {
                                // update all my comment status
                                mycomments.forEach { (c) in
                                    // check lastStatus and compare
                                    if c.status.intValue < status.intValue {
                                        let new = c
                                        // update comment
                                        new.status = .delivered
                                        QiscusCore.database.comment.save([new])
                                        QiscusCore.eventManager.gotMessageStatus(comment: new)
                                    }
                                    
                                }
                            }

                        }
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
        
        //check comment in db
        if let commentDB = QiscusCore.database.comment.find(id: comment.roomId){
            //ignored for status sent from my self / after postComment
        }else{
            QiscusCore.database.comment.save([comment])
        }
        
        
    }
    
    func didReceiveUser(typing: Bool, roomId: String, userEmail: String) {
        QiscusEventManager.shared.gotTyping(roomID: roomId, user: userEmail, value: typing)
        
       //typing event from outside room
        if let room = QiscusCore.database.room.find(id: roomId) {
            guard let member = QiscusCore.database.member.find(byEmail: userEmail) else { return }
            guard let postTyping = roomTypings[roomId] else { return }
            let typing = RoomTyping(roomID: roomId, user: member, typing: typing)
            postTyping(typing)
        }
        
    }
    
    func connectionState(change state: QiscusRealtimeConnectionState) {
        QiscusLogger.debugPrint("Qiscus realtime connection state \(state.rawValue)")
        self.state = state
        if let state : QiscusConnectionState = QiscusConnectionState(rawValue: state.rawValue) {
            QiscusEventManager.shared.connectionDelegate?.connectionState(change: state)
        }
        
        switch state {
        case .connected:
            QiscusLogger.debugPrint("Qiscus realtime connected")
            QiscusCore.shared.isOnline(true)
            resumePendingSubscribeTopic()
            QiscusEventManager.shared.connectionDelegate?.connected()
            
            QiscusCore.network.event_report(moduleName: "MQTT", event: "CONECTED", message: "Realtime Connected", onSuccess: { (success) in
                
            }) { (error) in
                QiscusLogger.debugPrint(error.message)
            }
            
            break
        case .disconnected:
            QiscusLogger.debugPrint("Qiscus realtime disconnected")
            QiscusCore.shared.isOnline(false)
            QiscusCore.heartBeat?.resume()
            break
        default:
            break
        }
    }
    
    
    func disconnect(withError err: Error?){
        if let error = err{
            QiscusEventManager.shared.connectionDelegate?.disconnect(withError: QError(message: error.localizedDescription))
            if QiscusCore.isLogined{
                QiscusCore.network.event_report(moduleName: "MQTT", event: "DISCONNECTED", message: error.localizedDescription, onSuccess: { (success) in
                    //success send report
                }) { (error) in
                    QiscusLogger.debugPrint(error.message)
                }
            }
        }else{
            QiscusEventManager.shared.connectionDelegate?.disconnect(withError: nil)
        }
    }

}

