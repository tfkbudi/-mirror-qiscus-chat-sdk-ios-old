//
//  ApiResponse.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

class ApiResponse<T> : Codable where T: Codable{
    let results : T
    let status : Int
    
    enum CodingKeys: String, CodingKey {
        
        case results = "results"
        case status = "status"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        results = try values.decode(T.self, forKey: .results)
        status = try values.decode(Int.self, forKey: .status)
    }
}
