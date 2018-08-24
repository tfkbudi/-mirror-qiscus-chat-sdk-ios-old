//
//  Auth.swift
//  QiscusCore
//
//  Created by Qiscus on 19/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import SwiftyJSON

public class UserResults : Codable {
    let user : UserModel
    
    enum CodingKeys: String, CodingKey {
        
        case user = "user"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decode(UserModel.self, forKey: .user)
    }
    
}

public class BlokedUserResults : Codable {
    let user : [UserModel]
    
    enum CodingKeys: String, CodingKey {
        
        case user = "blocked_user"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decode([UserModel].self, forKey: .user)
    }
    
}

public class UserModel {
    public let app : App
    public var avatarUrl : URL?
    public var email : String
    public var id : String
    public var lastCommentId : String
    public var lastSyncEventId : Int64
    public var pnIosConfigured : Bool
    public var rtKey : String
    public var token : String
    public var username : String
    
    enum CodingKeys: String, CodingKey {
        
        case app = "app"
        case avatarUrl = "avatar_url"
        case email = "email"
        case id = "id"
        case idStr = "id_str"
        case lastCommentId = "last_comment_id"
        case lastCommentIdStr = "last_comment_id_str"
        case lastSyncEventId = "last_sync_event_id"
        case pnAndroidConfigured = "pn_android_configured"
        case pnIosConfigured = "pn_ios_configured"
        case rtKey = "rtKey"
        case token = "token"
        case username = "username"
    }
    
    init(json: JSON) {
        avatarUrl       = json["avatar_url"].url ?? nil
        email           = json["email"].stringValue
        id              = json["id_str"].stringValue
        lastCommentId   = json["last_comment_id"].stringValue
        lastSyncEventId = json["last_sync_event_id"].int64Value
        pnIosConfigured  = json["pn_ios_configured"].boolValue
        rtKey           = json["rtKey"].stringValue
        token           = json["token"].stringValue
        username        = json["username"].stringValue
    }
}


public class App : Codable {
    public var code : String    = ""
    public var id : Int         = -1
    public var idStr : String   = ""
    public var name : String    = ""
    
    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case id = "id"
        case idStr = "id_str"
        case name = "name"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        id = try values.decode(Int.self, forKey: .id)
        idStr = try values.decode(String.self, forKey: .idStr)
        name = try values.decode(String.self, forKey: .name)
    }
    
}

open class MemberModel {
    public let avatarUrl : URL?
    public let email : String
    public var id : String
    public let lastCommentReadId : Int
    public let lastCommentReceivedId : Int
    public let username : String
    
    init(json: JSON) {
        self.id         = json["id_str"].stringValue
        self.username   = json["username"].stringValue
        self.avatarUrl  = json["avatar_url"].url ?? nil
        self.email      = json["email"].stringValue
        self.lastCommentReadId      = json["last_comment_read_id"].intValue
        self.lastCommentReceivedId  = json["last_comment_received_id"].intValue
    }
}
