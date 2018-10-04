//
//  CommentStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 19/08/18.
//

import Foundation

class CommentStorage : QiscusStorage {
    private var data : [CommentModel] = [CommentModel]()

    override init() {
        super.init()
        // MARK: TODO load data rooms from local storage to var data
    }
    
    func loadData() {
        self.data = self.loadFromLocal()
    }
    
    func removeAll() {
        data.removeAll()
        self.clearDB() // clear db
    }
    
    func delete(byUniqueID id: String) -> Bool {
        // remove from memory
        if let index = self.data.index(where: {$0.uniqId == id}) {
            data.remove(at: index)
        }else {
            return false
        }
        
        // remove from db
        if let db = Comment.find(predicate: NSPredicate(format: "uniqId = %@", id))?.first {
            db.remove()
        }else {
            return false
        }
        return true
    }
    
    func all() -> [CommentModel] {
        return data
    }
    
    func add(_ comment: CommentModel, onCreate: @escaping (CommentModel) -> Void, onUpdate: @escaping (CommentModel) -> Void) {
        self.background {
            // filter if comment exist update, if not add
            if let r = self.find(byUniqueID: comment.uniqId)  {
                // check new comment status, end status is read. sending - sent - deliverd - read
                if comment.status.hashValue <= r.status.hashValue {
                    return // just ignore, this part is trick from backend. after receiver update comment status then sender call api load comment somehow status still sent but sender already receive event status read/deliverd via mqtt
                }
                if !self.updateCommentDataEvent(old: r, new: comment) {
                    // add new
                    self.data.append(comment)
                    self.main {
                        onCreate(comment)
                    }
                }else {
                    // update
                    self.main {
                        onUpdate(comment)
                    }
                }
                self.save(comment) // else just update
            }else {
                // add new
                self.data.append(comment)
                self.save(comment)
                self.main {
                    onCreate(comment)
                }
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
    private func updateCommentDataEvent(old: CommentModel, new: CommentModel) -> Bool{
        if let index = data.index(where: { $0 === old }) {
            data[index] = new
            return true
        }else {
            return false
        }
    }
    
    func sort(_ data: [CommentModel]) -> [CommentModel]{
        var result = data
        //self.background {
            result.sort { (comment1, comment2) -> Bool in
                return comment1.unixTimestamp > comment2.unixTimestamp
            }
        //}
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
        self.main {
            self.data = self.loadFromLocal()
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
        result.unixTimestamp    = Int64(core.unixTimestamp)
        result.timestamp        = core.timestamp
        result.isPublicChannel  = core.isPublicChannel
        if let payload = core.payload {
            result.payload = payload.dict2json()
        }
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
        guard let timestamp = data.timestamp else { return result }
        guard let commentBeforeId = data.commentBeforeId else { return result }
        guard let payload = data.payload else { return result }

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
        result.unixTimestamp    = Int64(data.unixTimestamp)
        result.timestamp        = timestamp
        result.isPublicChannel  = data.isPublicChannel
        result.payload          = convertToDictionary(from: payload)
        
        for s in CommentStatus.all {
            if s.rawValue == status {
                result.status = s
            }
        }
        
        return result
    }
    
    private func convertToDictionary(from text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
}

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func dict2json() -> String {
        return json
    }
}

