//
//  GenericModel.swift
//  QiscusCore
//
//  Created by Qiscus on 13/08/18.
//

import Foundation

public enum DeleteType {
    case forMe
    case forEveryone
}

public class UnreadModel : Codable {
    public let unread : Int
    
    enum CodingKeys: String, CodingKey {
        case unread = "total_unread_count"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        unread = try values.decode(Int.self, forKey: .unread)
    }
}
