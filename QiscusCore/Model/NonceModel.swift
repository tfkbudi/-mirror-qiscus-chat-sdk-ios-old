//
//  NonceModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 24/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

public struct QNonce : Codable {
    public let expiredAt : Int
    public let nonce : String
    
    enum CodingKeys: String, CodingKey {
        
        case expiredAt = "expired_at"
        case nonce = "nonce"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        expiredAt = try values.decode(Int.self, forKey: .expiredAt)
        nonce = try values.decode(String.self, forKey: .nonce)
    }
    
}
