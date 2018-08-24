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
}

class UserApiResponse {
    static func blockedUsers(from json: JSON) -> [RoomModel]? {
        if let rooms = json["blocked_user"].array {
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
