 //
//  QiscusStorage.swift
//  QiscusCore
//
//  Created by Qiscus on 16/08/18.
//
//  Next to be handle all blueprint function by other model, like QiscusStorage/DB

import Foundation

public class QiscusStorage {
    static var shared   : QiscusStorage = QiscusStorage()
    let fileManager     : QiscusFileManager = QiscusFileManager()
    
    init() { }
    
    // take time, coz search in all rooms
    public func getMember(byEmail email: String) -> MemberModel? {
        let rooms = QiscusCore.database.room.all()
        for room in rooms {
            guard let participants = room.participants else { return nil }
            for p in participants {
                if p.email == email {
                    return p
                }
            }
        }
        return nil
    }
    
    public func getMember(byEmail email: String, inRoom room: RoomModel) -> MemberModel? {
        guard let participants = room.participants else { return nil }
        for p in participants {
            if p.email == email {
                return p
            }
        }
        return nil
    }
}
