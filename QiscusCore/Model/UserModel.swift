//
//  Auth.swift
//  QiscusCore
//
//  Created by Qiscus on 19/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

public struct UserResults : Codable {
    let user : QUser
    
    enum CodingKeys: String, CodingKey {
        
        case user = "user"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decode(QUser.self, forKey: .user)
    }
    
}

public struct QUser : Codable {
    let app : App
    let avatarUrl : String
    let email : String
    let id : Int
    let idStr : String
    let lastCommentId : Int
    let lastCommentIdStr : String
    let lastSyncEventId : Int
    let pnAndroidConfigured : Bool
    let pnIosConfigured : Bool
    let rtKey : String
    let token : String
    let username : String
    
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
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        app = try values.decode(App.self, forKey: .app)
        avatarUrl = try values.decode(String.self, forKey: .avatarUrl)
        email = try values.decode(String.self, forKey: .email)
        id = try values.decode(Int.self, forKey: .id)
        idStr = try values.decode(String.self, forKey: .idStr)
        lastCommentId = try values.decode(Int.self, forKey: .lastCommentId)
        lastCommentIdStr = try values.decode(String.self, forKey: .lastCommentIdStr)
        lastSyncEventId = try values.decode(Int.self, forKey: .lastSyncEventId)
        pnAndroidConfigured = try values.decode(Bool.self, forKey: .pnAndroidConfigured)
        pnIosConfigured = try values.decode(Bool.self, forKey: .pnIosConfigured)
        rtKey = try values.decode(String.self, forKey: .rtKey)
        token = try values.decode(String.self, forKey: .token)
        username = try values.decode(String.self, forKey: .username)
    }
    
}


public struct App : Codable {
    let code : String
    let id : Int
    let idStr : String
    let name : String
    
    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case id = "id"
        case idStr = "id_str"
        case name = "name"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        id = try values.decode(Int.self, forKey: .id)
        idStr = try values.decode(String.self, forKey: .idStr)
        name = try values.decode(String.self, forKey: .name)
    }
    
}
