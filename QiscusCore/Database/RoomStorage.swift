//
//  RoomStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 16/08/18.
//
//  Responsiblilities :
//  save room from restAPI in temp(variable)
//  save room in local storage
//  get rooms from local storage

import Foundation

class RoomStorage {
    private var data : [RoomModel] = [RoomModel]()
    var delegate = QiscusCore.eventManager.delegate

    init() {
        // MARK: TODO load data rooms from local storage to var data
        let local = loadFromLocal()
        data = sort(local)
    }
    
    func removeAll() {
        data.removeAll()
        self.clearDB()
    }
    
    func all() -> [RoomModel] {
        return data
    }
    
    func add(_ value: [RoomModel]) {
        // filter if room exist update, if not add
        for room in value {
            if let r = find(byID: room.id)  {
                if !updateRoomDataEvent(old: r, new: room) {
                    // add new room
                    data.append(room)
                    // publish event add new room
                    delegate?.gotNew(room: room)
                }
            }else {
                // add new room
                data.append(room)
                save(room)
                // publish event add new room
                delegate?.gotNew(room: room)
            }
        }
        data = sort(data)
        // mark Todo update last comment
        QiscusLogger.debugPrint("number of room in local temp : \(data.count)")
    }
    
    // update/replace === identical object
    private func updateRoomDataEvent(old: RoomModel, new: RoomModel) -> Bool{
        if let index = data.index(where: { $0 === old }) {
            data[index] = new
            save(new)
            return true
        }else {
            return false
        }
    }
    
    func find(byID id: String) -> RoomModel? {
        if data.isEmpty {
            return nil
        }else {
            return data.filter{ $0.id == id }.first
        }
    }
    
    // MARK: TODO Sorting not work
    func sort(_ data: [RoomModel]) -> [RoomModel]{
        var result = data
        result.sort { (room1, room2) -> Bool in
            if let comment1 = room1.lastComment, let comment2 = room2.lastComment {
                return comment1.unixTimestamp > comment2.unixTimestamp
            }else {
                return false
            }
        }
        return result
    }
    
    /// Update last comment in room
    ///
    /// - Parameter comment: new comment object
    /// - Returns: true if room already exist and false if room unavailable
    func updateLastComment(_ comment: CommentModel) -> Bool {
        if let r = find(byID: String(comment.roomId)) {
            let new = r
            new.lastComment = comment
            // check uniqtimestamp if nil, assume new comment from your
            if comment.unixTimestamp > 0 {
                new.unreadCount = new.unreadCount + 1
            }
            save(new)
            // check data exist and update
            let isUpdate = updateRoomDataEvent(old: r, new: new)
            data = sort(data) // check data source
            return isUpdate
        }else {
            return false
        }
    }
    
    
    /// Update unread count -1 to read
    ///
    /// - Parameter comment: new comment object already read
    /// - Returns: true if room already exist and false if room unavailable
    func updateUnreadComment(_ comment: CommentModel) -> Bool {
        if let r = find(byID: String(comment.roomId)) {
            let new = r
            // compare comment
            if let lastComment = r.lastComment {
                if comment.id == lastComment.id {
                    new.unreadCount = new.unreadCount - 1
                    let isUpdate = updateRoomDataEvent(old: r, new: new)
                    // update data local
//                    saveToLocal(data)
                    return isUpdate
                }else { return false }
            }else { return false }
        }else {
            return false
        }
    }
    
    // improve unread count, handle multiple login
    func readComments(_ comment : [CommentModel]) {
        // calculate
        
    }
    
}

// MARK: Local Database
extension RoomStorage {
    func find(predicate: NSPredicate) -> [RoomModel]? {
        guard let rooms = Room.find(predicate: predicate) else { return nil}
        var results = [RoomModel]()
        for r in rooms {
            results.append(map(r))
        }
        return results
    }
    
    func clearDB() {
        Room.clear()
    }
    
    func save(_ data: RoomModel) {
        if let db = Room.find(predicate: NSPredicate(format: "id = %@", data.id))?.first {
            let _comment = map(data, data: db) // update value
            _comment.update() // save to db
        }else {
            // save new room
            let _comment = self.map(data)
            _comment.save()
            // get last comment and save to comment db
            if let comment = data.lastComment {
                CommentStorage().save(comment)
            }
        }
    }
    
    func loadFromLocal() -> [RoomModel] {
        var results = [RoomModel]()
        let roomsdb = Room.all()
        
        for room in roomsdb {
            let _room = map(room)
            results.append(_room)
        }
        return results
    }
    
    /// create or update db object
    ///
    /// - Parameters:
    ///   - core: core model
    ///   - data: db model, if exist just update falue
    /// - Returns: db object
    private func map(_ core: RoomModel, data: Room? = nil) -> Room {
        var result : Room
        if let _result = data {
            result = _result // Update data
        }else {
            result = Room.generate() // prepare create new
        }
        result.id            = core.id
        result.unreadCount   = Int16(core.unreadCount)
        result.name          = core.name
        result.avatarUrl     = core.avatarUrl?.absoluteString
        result.options       = core.options
        result.lastCommentId    = core.lastComment?.id
        result.type          = core.type.rawValue
        return result
    }
    
    private func map(_ room: Room) -> RoomModel {
        let result = RoomModel()
        // check record data
        guard let id = room.id else { return result }
        guard let name = room.name else { return result }
        guard let avatarUrl = room.avatarUrl else { return result }
        guard let type = room.type else { return result }
        guard let lastCommentid = room.lastCommentId else { return result }
        
        // room type
        for t in RoomType.all {
            if type == t.rawValue {
                result.type = t
            }
        }
        
        // MARK: TODO get participants
        //            _room.participants
        result.id            = id
        result.unreadCount   = Int(room.unreadCount)
        result.name          = name
        result.avatarUrl     = URL(string: avatarUrl)
        result.options       = room.options
        // check comment
        result.lastComment   = CommentStorage().find(predicate: NSPredicate(format: "id = %@", lastCommentid))?.first
        return result
    }
}
