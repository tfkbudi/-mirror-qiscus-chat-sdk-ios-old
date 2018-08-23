//
//  CommentStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 19/08/18.
//

import Foundation

class CommentStorage {
    private var data : [CommentModel] = [CommentModel]()

    init() {
        // MARK: TODO load data rooms from local storage to var data
    }
    
    func removeAll() {
        data.removeAll()
    }
    
    func all() -> [CommentModel] {
        return data
    }
    
    func add(_ value: [CommentModel]) {
        // filter if room exist update, if not add
        for comment in value {
            if let r = find(byUniqueID: comment.uniqueTempId)  {
                if !updateRoomDataEvent(old: r, new: comment) {
                    // add new
                    data.append(comment)
                }
            }else {
                // add new
                data.append(comment)
            }
        }
    }
    
    func find(byID id: String) -> CommentModel? {
        if data.isEmpty {
            return nil
        }else {
            return data.filter{ $0.id == id }.first
        }
    }
    
    func find(byUniqueID id: String) -> CommentModel? {
        if data.isEmpty {
            return nil
        }else {
            return data.filter{ $0.uniqueTempId == id }.first
        }
    }
    
    func find(byRoomID id: String) -> [CommentModel]? {
        if data.isEmpty {
            return nil
        }else {
            let result = data.filter{ $0.roomId == id }
            return sort(result) // short by unix
        }
    }
    
    // update/replace === identical object
    private func updateRoomDataEvent(old: CommentModel, new: CommentModel) -> Bool{
        if let index = data.index(where: { $0 === old }) {
            data[index] = new
            QiscusLogger.debugPrint("comment \(new.id), unreadCount \(new.id)")
            return true
        }else {
            return false
        }
    }
    
    func sort(_ data: [CommentModel]) -> [CommentModel]{
        var result = data
        result.sort { (comment1, comment2) -> Bool in
            return comment1.unixTimestamp > comment2.unixTimestamp
        }
        return result
    }
}
