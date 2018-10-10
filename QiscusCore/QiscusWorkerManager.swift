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
        // sync
        self.sync()
        // send pending
        self.pending()
        // send sending, when process resend then unfortunedly crash/closed
        self.sending()
    }
    
    private func sync() {
        QiscusCore.shared.sync(onSuccess: { (comments) in
            // save comment in local
            QiscusCore.database.comment.save(comments)
        }, onError: { (error) in
            QiscusLogger.errorPrint("sync error, \(error.message)")
        })
    }
    
    private func pending() {
        guard let comments = QiscusCore.database.comment.find(status: .pending) else { return }
        comments.reversed().forEach { (c) in
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
