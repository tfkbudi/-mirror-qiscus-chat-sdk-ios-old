//
//  ApiResponse.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

class ApiResponse {
    static func decode(from data: Data) -> JSON {
        let json = JSON(data)
        let result = json["results"]
        return result
    }
    
    static func decode(string data: String) -> JSON {
        let json = JSON.init(parseJSON: data)
        return json
    }
    
    static func decode(unread data: Data) -> Int {
        let json = JSON(data)
        let unread = json["total_unread_count"].intValue
        return unread
    }
}

class UserApiResponse {
    static func blockedUsers(from json: JSON) -> [UserModel]? {
        if let rooms = json["blocked_user"].array {
            var results = [UserModel]()
            for room in rooms {
                let data = UserModel(json: room)
                results.append(data)
            }
            return results
        }else {
            return nil
        }
    }
    
    static func user(from json: JSON) -> UserModel {
        let comment = json["user"]
        return UserModel(json: comment)
    }
}

class RoomApiResponse {
    static func rooms(from json: JSON) -> [RoomModel]? {
        if let rooms = json["rooms_info"].array {
            var results = [RoomModel]()
            for room in rooms {
                let data = RoomModel(json: room)
                results.append(data)
            }
            return results
        }else {
            return nil
        }
    }
    
    static func room(from json: JSON) -> RoomModel {
        let comment = json["room"]
        return RoomModel(json: comment)
    }
    
    static func meta(from json: JSON) -> Meta {
        let meta = json["meta"]
        return Meta(json: meta)
    }
    
    static func addParticipants(from json: JSON) -> [MemberModel]? {
        if let members = json["participants_added"].array {
            var results = [MemberModel]()
            for member in members {
                let data = MemberModel(json: member)
                results.append(data)
            }
            return results
        }else {
            return nil
        }
    }

}

class CommentApiResponse {
    static func comments(from json: JSON) -> [CommentModel]? {
        if let comments = json["comments"].array {
            var results = [CommentModel]()
            for comment in comments {
                let data = CommentModel(json: comment)
                results.append(data)
            }
            return results
        }else {
            return nil
        }
    }
    
    static func comment(from json: JSON) -> CommentModel {
        let comment = json["comment"]
        return CommentModel(json: comment)
    }
}
