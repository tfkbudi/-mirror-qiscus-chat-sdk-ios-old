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
    var saveTask: DispatchWorkItem?
    var filename : String = "QiscusRooms.json"
    init() {
        // MARK: TODO load data rooms from local storage to var data
        self.data = loadFromLocal()
    }
    
    func removeAll() {
        data.removeAll()
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
                // publish event add new room
                delegate?.gotNew(room: room)
            }
        }
        data = sort(data)
        self.saveToLocal(data)
        // mark Todo update last comment
        QiscusLogger.debugPrint("number of room in local temp : \(data.count)")
    }
    
    // update/replace === identical object
    private func updateRoomDataEvent(old: RoomModel, new: RoomModel) -> Bool{
        if let index = data.index(where: { $0 === old }) {
            data[index] = new
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
            // check data exist and update
            let isUpdate = updateRoomDataEvent(old: r, new: new)
            data = sort(data) // check data source
            saveToLocal(data) // update data local
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
                    saveToLocal(data)
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

// MARK: Local Storage
extension RoomStorage {
    func loadFromLocal() -> [RoomModel] {
        // load from file
//        if let rooms = Storage.find(filename, in: .document, as: [RoomModel].self) {
//            return rooms
//        }else {
            return [RoomModel]() // return emty rooms
        //}
    }
    
    func saveToLocal(_ data: [RoomModel]) {
        self.saveTask?.cancel()
        let task = DispatchWorkItem {
            self.saveToFile()
        }
        self.saveTask = task
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: task)
    }
    
    private func saveToFile() {
        DispatchQueue.global(qos: .background).async {
           // Storage.save(self.data, to: .document, as: self.filename)
        }
    }
}
