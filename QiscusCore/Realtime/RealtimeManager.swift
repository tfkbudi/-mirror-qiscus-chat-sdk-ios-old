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
    
    // mock
    
    init(appName: String) {
        let config = QiscusRealtimeConfig(appName: appName)
        client = QiscusRealtime.init(withConfig: config)
    }
    
    func connect(username: String, password: String) {
        client.connect(username: username, password: password, delegate: self)
    }
    
}

extension RealtimeManager: QiscusRealtimeConnectionDelegate {
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

