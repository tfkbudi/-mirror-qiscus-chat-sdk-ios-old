//
//  QiscusWorkerManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/10/18.
//

import Foundation

class QiscusWorkerManager {
    
    func resume() {
        // MARK : Improve realtime state acurate disconnected
        // if QiscusCore.realtime.state == .disconnected {
        if QiscusCore.isLogined {
            self.sync()
            self.pending()
        }
    }
    
    private func syncEvent() {
        //sync event
        let id = ConfigManager.shared.syncEventId
        QiscusCore.network.syncEvent(lastId: id, onSuccess: { (events) in
            events.forEach({ (event) in
                if event.id == id { return }
                
                switch event.actionTopic {
                case .deletedMessage :
                    let ids = event.getDeletedMessageUniqId()
                    ids.forEach({ (id) in
                        if let comment = QiscusCore.database.comment.find(uniqueId: id) {
                            _ = QiscusCore.database.comment.delete(comment)
                        }
                    })
                    ConfigManager.shared.syncEventId = event.id
                case .clearRoom:
                    let ids = event.getClearRoomUniqId()
                    ids.forEach({ (id) in
                        if let room = QiscusCore.database.room.find(uniqID: id) {
                            _ = QiscusCore.database.comment.clear(inRoom: room.id, timestamp: event.timestamp)
                        }
                    })
                    ConfigManager.shared.syncEventId = event.id
                }
                
            })
        }) { (error) in
            QiscusLogger.errorPrint("sync error, \(error.message)")
        }
    }
    
    private func sync() {
        let id = ConfigManager.shared.syncId
        QiscusCore.shared.sync(lastCommentReceivedId: id,onSuccess: { (comments) in
            DispatchQueue.global(qos: .background).async {
                // save comment in local
                QiscusCore.database.comment.save(comments)
                self.syncEvent()
                if let c = comments.first {
                    ConfigManager.shared.syncId = c.id
                }
            }
           
        }, onError: { (error) in
            QiscusLogger.errorPrint("sync error, \(error.message)")
        })
    }
    
    private func pending() {
        guard let comments = QiscusCore.database.comment.find(status: .pending) else { return }
        comments.reversed().forEach { (c) in
            // validation comment prevent id
            if c.uniqId.isEmpty { QiscusCore.database.comment.evaluate(); return }
            QiscusCore.shared.sendMessage(roomID: c.roomId, comment: c, onSuccess: { (response) in
                QiscusLogger.debugPrint("success send pending message \(response.uniqId)")
            }, onError: { (error) in
                QiscusLogger.errorPrint("failed send pending message \(c.uniqId)")
            })
        }
    }
    
    private func sending() {
        guard let comments = QiscusCore.database.comment.find(status: .sending) else { return }
        comments.reversed().forEach { (c) in
            QiscusCore.shared.sendMessage(roomID: c.roomId, comment: c, onSuccess: { (response) in
                QiscusLogger.debugPrint("success send pending message \(response.uniqId)")
            }, onError: { (error) in
                QiscusLogger.errorPrint("failed send pending message \(c.uniqId)")
            })
        }
    }
}
