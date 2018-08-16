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
    var data : [RoomModel] = [RoomModel]()
    
    init() {
        // MARK: TODO load data rooms from local storage to var data
    }
    
    func add(_ value: [RoomModel]) {
        // filter if room exist update, if not add
        for room in value {
            if let r = find(byID: room.id)  {
                // update/replace === identical object
                if let index = data.index(where: { $0 === r }) {
                    data[index] = room
                }else {
                    // add new room
                    data.insert(room, at: 0)
                }
            }else {
                // add new room
                data.insert(room, at: 0)
            }
        }
        // mark Todo update last comment
        QiscusLogger.debugPrint("number of room in local temp : \(data.count)")
    }
    
    func find(byID id: String) -> RoomModel? {
        if data.isEmpty {
            return nil
        }else {
            return data.filter{ $0.id == id }.first
        }
    }
    
   
}
