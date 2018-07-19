//
//  Auth.swift
//  QiscusCore
//
//  Created by Qiscus on 19/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

/**
 {
 "status": 200,
 "results": {
         "user": {
             "id": 1,
             "email": "email@qiscus.com",
             "username": "Johnny Cage",
             "avatar": {
                 "avatar": {
                    "url": "http://imagebucket.com/image.jpg"
                 }
             },
             "avatar_url": "https://myimagebucket.com/image.jpg",
             "token": "abcde1234defgh",
             "rtKey": "RT_KEY_HERE",
             "pn_ios_configured": true,
             "pn_android_configured": true
         }
    }
 }
*/
struct UserAPIResponse {
    let status  : Int
    let results : [UserModel]
}

extension UserAPIResponse : Decodable {
    private enum UserAPIResponseCodingKey: String, CodingKey {
        case status
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserAPIResponseCodingKey.self)
        
        status  = try container.decode(Int.self, forKey: .status)
        results  = try container.decode([UserModel].self, forKey: .results)
    }
}

internal struct UserModel {
    let id      : Int
    let email   : String
    let username    : String
    let avatar_url  : String
    let token       : String
    let rtKey       : String
    let pnIOSConfig  : Bool
}

extension UserModel : Decodable {
    
    
//    init(from decoder: Decoder) throws {
//        
//    }
}
