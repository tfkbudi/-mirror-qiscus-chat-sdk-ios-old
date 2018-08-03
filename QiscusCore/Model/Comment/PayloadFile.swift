//
//  QiscusModel.swift
//  QiscusCore
//
//  Created by Qiscus on 02/08/18.
//  Credits :

import Foundation

/**
 File Attachment payload:
 {
     "url": "https:res.cloudinary.com/qiscus/image/upload/USWiylE7Go/ios-15049438515185.png",
     "caption": "Ini gambar siapa?",
     "file_name": "Nama file",
     "size": 0,
     "pages": 1,
     "encryption_key": "ashasgewfrsasfasra"
 }
 */

public class PayloadFile : Payload {
    public let caption : String
    public let url : URL
    public let fileName : String
    
    enum CodingKeys: String, CodingKey {
        case caption = "caption"
        case url    = "url"
        case fileName = "file_name"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        caption = try values.decode(String.self, forKey: .caption)
        url     = try values.decode(URL.self, forKey: .url)
        fileName = try values.decode(String.self, forKey: .fileName)
        super.init()
    }
}
