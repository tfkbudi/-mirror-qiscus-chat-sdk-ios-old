//
//  PayloadContact.swift
//  QiscusCore
//
//  Created by Qiscus on 03/08/18.
//

import Foundation

/**
 {
    "name": "Evan",
    "value": "e@qiscus.com",
    "type": "email"
 }
*/

public class PayloadContact : Payload {
    public let name : String?
    public let value : String?
    public let type : String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
        case type = "type"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        super.init()
    }
    
}
