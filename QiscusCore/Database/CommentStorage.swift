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
        self.data = self.loadFromLocal()
    }
    
    func removeAll() {
        data.removeAll()
        self.clearDB() // clear db
    }
    
    
//    func delete(byID: String) {
//        
//    }
    
    func all() -> [CommentModel] {
        return data
    }
    
    func add(_ value: [CommentModel]) {
        // filter if room exist update, if not add
        for comment in value {
            if let r = find(byUniqueID: comment.uniqId)  {
                if !updateRoomDataEvent(old: r, new: comment) {
                    // add new
                    data.append(comment)
                    save(comment)
                }
            }else {
                // add new
                data.append(comment)
                save(comment)
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
            return data.filter{ $0.uniqId == id }.first
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

// MARK: Comment database
extension CommentStorage {
    func find(predicate: NSPredicate) -> [CommentModel]? {
        guard let data = Comment.find(predicate: predicate) else { return nil}
        var results = [CommentModel]()
        for r in data {
            results.append(map(r))
        }
        return results
    }
    
    func clearDB() {
        Comment.clear()
    }
    
    func save(_ data: CommentModel) {
        if let db = Comment.find(predicate: NSPredicate(format: "id = %@", data.id))?.first {
            let _comment = map(data, data: db) // update value
            _comment.update() // save to db
        }else {
            let _comment = self.map(data)
            _comment.save()
        }
    }
    
    private func loadFromLocal() -> [CommentModel] {
        var results = [CommentModel]()
        let db = Comment.all()
        
        for comment in db {
            let _comment = map(comment)
            results.append(_comment)
        }
        return results
    }
    
    
    /// create or update db object
    ///
    /// - Parameters:
    ///   - core: core model
    ///   - data: db model, if exist just update falue
    /// - Returns: db object
    private func map(_ core: CommentModel, data: Comment? = nil) -> Comment {
        var result : Comment
        if let _result = data {
            result = _result // Update data
        }else {
            result = Comment.generate() // prepare create new
        }
        result.id               = core.id
        result.type             = core.type
        result.userAvatarUrl    = core.userAvatarUrl?.absoluteString
        result.username         = core.username
        result.userEmail        = core.userEmail
        result.userId           = core.userId
        result.message          = core.message
        result.extras           = core.extras
        result.uniqId           = core.uniqId
        result.roomId           = core.roomId
        result.commentBeforeId  = core.commentBeforeId
        result.status           = core.status.rawValue
        return result
    }
    
    /// map from db model to core model
    private func map(_ data: Comment) -> CommentModel {
        let result = CommentModel()
        // check record data
        guard let id = data.id else { return result }
        guard let message = data.message else { return result }
        guard let status = data.status else { return result }
        guard let type = data.type else { return result }
        guard let userId = data.userId else { return result }
        guard let username = data.username else { return result }
        guard let userEmail = data.userEmail else { return result }
        guard let userAvatarUrl = data.userAvatarUrl else { return result }
        guard let extras = data.extras else { return result }
        guard let roomId = data.roomId else { return result }
        guard let uniqueId = data.uniqId else { return result }
        guard let commentBeforeId = data.commentBeforeId else { return result }

        result.id               = id
        result.type             = type
        result.userAvatarUrl    = URL(string: userAvatarUrl)
        result.username         = username
        result.userEmail        = userEmail
        result.userId           = userId
        result.message          = message
        result.extras           = extras
        result.uniqId           = uniqueId
        result.roomId           = roomId
        result.commentBeforeId  = commentBeforeId
        result.isDeleted        = data.isDeleted
        
        for s in CommentStatus.all {
            if s.rawValue == status {
                result.status = s
            }
        }
        
        return result
    }
}

// MARK: TODO map
//public internal(set) var isPublicChannel      : Bool          = false
//public var payload              : [String:Any]? = nil
//public internal(set) var timestamp            : String        = ""
//public internal(set) var unixTimestamp        : Int           = 0

