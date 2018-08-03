//
//  PayloadContact.swift
//  QiscusCore
//
//  Created by Qiscus on 03/08/18.
//

import Foundation

/**
 {
     "name": "Mirota Kampus 2 Simanjuntak",
     "address": "Jalan C Simanjuntak No.70, Terban, Gondokusuman, Kota Yogyakarta, Daerah Istimewa Yogyakarta 55223",
     "latitude": -7.776235,
     "longitude": 110.374928,
     "map_url": "http://maps.google.com/?q=-7.776235,110.374928",
     "encrypted_latitude": "asgahsgtwehgayw",
     "encrypted_longitude": "ashjshtweyghgas"
 }
 */

public class PayloadLocation : Payload {
    public let name : String?
    public let address : String?
    public let latitude : Double?
    public let longitude : Double?
    public let map_url : String?
    public let encrypted_latitude : String?
    public let encrypted_longitude : String?
    
    enum CodingKeys: String, CodingKey {

        case name = "name"
        case address = "address"
        case latitude = "latitude"
        case longitude = "longitude"
        case map_url = "map_url"
        case encrypted_latitude = "encrypted_latitude"
        case encrypted_longitude = "encrypted_longitude"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        map_url = try values.decodeIfPresent(String.self, forKey: .map_url)
        encrypted_latitude = try values.decodeIfPresent(String.self, forKey: .encrypted_latitude)
        encrypted_longitude = try values.decodeIfPresent(String.self, forKey: .encrypted_longitude)
        super.init()
    }
    
}
