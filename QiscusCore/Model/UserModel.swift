//
//  Auth.swift
//  QiscusCore
//
//  Created by Qiscus on 19/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import SwiftyJSON

public struct UserModel {
    var app                     : App?      = nil
    public var avatarUrl        : URL       = URL(string: "http://")!
    public var email            : String    = ""
    public var id               : String    = ""
    public var lastCommentId    : String    = ""
    public var lastSyncEventId  : Int64     = -1
    public var pnIosConfigured   : Bool      = false
    public var rtKey            : String    = ""
    public var token            : String    = ""
    public var username         : String    = ""
    public var extras           : [String:Any]? = nil
    
    init() { }
    
    init(json: JSON) {
        avatarUrl       = json["avatar_url"].url ?? URL(string: "http://")!
        email           = json["email"].stringValue
        id              = json["id_str"].stringValue
        lastCommentId   = json["last_comment_id"].stringValue
        lastSyncEventId = json["last_sync_event_id"].int64Value
        pnIosConfigured  = json["pn_ios_configured"].boolValue
        rtKey           = json["rtKey"].stringValue
        token           = json["token"].stringValue
        username        = json["username"].stringValue
        extras          = json["extras"].dictionaryObject
        let _app        = json["app"]
        app             = App(json: _app)
    }
}

class App  {
     var code : String    = ""
     var id : String      = ""
     var name : String    = ""

    init(json: JSON) {
        code    = json["code"].stringValue
        id      = json["id_str"].stringValue
        name    = json["name"].stringValue
    }
}

open class MemberModel {
    public var avatarUrl : URL? = nil
    public var email : String   = ""
    public var id : String      = ""
    public var lastCommentReadId : Int  = -1
    public var lastCommentReceivedId : Int  = -1
    public var username : String    = ""
    
    init() { }
    
    init(json: JSON) {
        self.id         = json["id_str"].stringValue
        self.username   = json["username"].stringValue
        self.avatarUrl  = json["avatar_url"].url ?? nil
        self.email      = json["email"].stringValue
        self.lastCommentReadId      = json["last_comment_read_id"].intValue
        self.lastCommentReceivedId  = json["last_comment_received_id"].intValue
    }
}
