//
//  QiscusWorkerManager.swift
//  QiscusCore
//
//  Created by Qiscus on 09/10/18.
//

import Foundation

class QiscusWorkerManager {
    
    func resume() {
        // sync
        self.sync()
        // send pending
        self.pending()
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
        comments.forEach { (c) in
            QiscusCore.shared.sendMessage(roomID: c.roomId, comment: c, onSuccess: { (response) in
                QiscusLogger.debugPrint("success send pending message \(response.uniqId)")
            }, onError: { (error) in
                QiscusLogger.errorPrint("failed send pending message \(c.uniqId)")
            })
        }
    }
}
