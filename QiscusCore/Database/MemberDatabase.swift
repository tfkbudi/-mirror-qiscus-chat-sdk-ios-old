//
//  MemberDatabase.swift
//  QiscusCore
//
//  Created by Qiscus on 13/09/18.
//

import Foundation

class MemberDatabase {
    private var data : [MemberModel] = [MemberModel]()
    var delegate = QiscusCore.eventManager.delegate
    
    init() {
        // MARK: TODO load data rooms from local storage to var data
        
    }
    
    func loadData() {
        self.data = loadFromLocal()
    }
    
    func removeAll() {
        data.removeAll()
        self.clearDB()
    }
    
    func all() -> [MemberModel] {
        return data
    }
    
    func add(_ value: [MemberModel]) {
        // filter if room exist update, if not add
        for room in value {
            if let r = find(byID: room.id)  {
                if !updateMemberDataEvent(old: r, new: room) {
                    // add new room
                    data.append(room)
                }
            }else {
                // add new room
                data.append(room)
                save(room)
            }
        }
        // mark Todo update last comment
        QiscusLogger.debugPrint("number of room in local temp : \(data.count)")
    }
    
    // update/replace === identical object
    private func updateMemberDataEvent(old: MemberModel, new: MemberModel) -> Bool{
        if let index = data.index(where: { $0 === old }) {
            data[index] = new
            save(new)
            return true
        }else {
            return false
        }
    }
    
    func find(byID id: String) -> MemberModel? {
        if data.isEmpty {
            return nil
        }else {
            return data.filter{ $0.id == id }.first
        }
    }
}

// MARK: Local Database
extension MemberDatabase {
    func find(predicate: NSPredicate) -> [MemberModel]? {
        guard let members = Member.find(predicate: predicate) else { return nil}
        var results = [MemberModel]()
        for r in members {
            results.append(map(r))
        }
        return results
    }
    
    func clearDB() {
        Room.clear()
    }
    
    func save(_ data: MemberModel) {
        if let db = Member.find(predicate: NSPredicate(format: "id = %@", data.id))?.first {
            let _comment = map(data, data: db) // update value
            _comment.update() // save to db
        }else {
            // save new member
            let _comment = self.map(data)
            _comment.save()
        }
    }
    
    func loadFromLocal() -> [MemberModel] {
        var results = [MemberModel]()
        let db = Member.all()
        
        for member in db {
            let _member = map(member)
            results.append(_member)
        }
        return results
    }
    
    /// create or update db object
    ///
    /// - Parameters:
    ///   - core: core model
    ///   - data: db model, if exist just update falue
    /// - Returns: db object
    internal func map(_ core: MemberModel, data: Member? = nil) -> Member {
        var result : Member
        if let _result = data {
            result = _result // Update data
        }else {
            result = Member.generate() // prepare create new
        }
        result.id           = core.id
        result.avatarUrl    = core.avatarUrl?.absoluteString
        result.email        = core.email
        result.username     = core.username
        result.lastCommentReadId        = Int64(core.lastCommentReadId)
        result.lastCommentReceivedId    = Int64(core.lastCommentReceivedId)
        return result
    }
    
    internal func map(_ member: Member) -> MemberModel {
        let result = MemberModel()
        // check record data
        guard let id = member.id else { return result }
        guard let name = member.username else { return result }
        guard let email = member.email else { return result }
        guard let avatarUrl = member.avatarUrl else { return result }

        result.id            = id
        result.username      = name
        result.email         = email
        result.avatarUrl     = URL(string: avatarUrl)
        result.lastCommentReceivedId    = Int(member.lastCommentReceivedId)
        result.lastCommentReadId        = Int(member.lastCommentReadId)

        return result
    }
}
