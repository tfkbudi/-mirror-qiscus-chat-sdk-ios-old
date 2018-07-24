//
//  NonceModel.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 24/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

public struct NonceApiResponse : Codable {
    let results : QNonce
    let status : Int
    
    enum CodingKeys: String, CodingKey {
        
        case results = "results"
        case status = "status"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        results = try values.decode(QNonce.self, forKey: .results)
        status = try values.decode(Int.self, forKey: .status)
    }
    
}

public struct QNonce : Codable {
    let expiredAt : Int
    let nonce : String
    
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
