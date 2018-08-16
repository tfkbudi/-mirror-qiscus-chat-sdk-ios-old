//
//  QiscusStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 16/08/18.
//

import Foundation

class QiscusStorage {
    static var shared : QiscusStorage = QiscusStorage()
    private var room : RoomStorage!
    
    init() {
        room = RoomStorage()
    }
    
    func getRooms() -> [RoomModel] {
        return room.data
    }
    
    func saveRoom(_ data: RoomModel) {
        room.add([data])
    }
    
    func saveRoom(_ data: [RoomModel]) {
        room.add(data)
    }
    
    func clearRoom() {
        room.data.removeAll()
    }
    
    func findRoom(byID id: String) -> RoomModel? {
        return room.find(byID: id)
    }
}
