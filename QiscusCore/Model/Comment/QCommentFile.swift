//
//  QCommentFile.swift
//  QiscusCore
//
//  Created by Qiscus on 02/08/18.
//

import Foundation

/**
 payload:
 {
     "url": "https://res.cloudinary.com/qiscus/image/upload/USWiylE7Go/ios-15049438515185.png",
     "caption": "Ini gambar siapa?",
     "file_name": "Nama file",
     "size": 0,
     "pages": 1,
     "encryption_key": "ashasgewfrsasfasra" // Optional, Base64 of simetric key used to encrypt and decrypt file
 }
 */


class FilePayload : Codable {
    let caption : String
    let url : URL
    let fileName : String
    
    enum CodingKeys: String, CodingKey {
        case caption = "caption"
        case url    = "url"
        case fileName = "file_name"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        caption = try values.decode(String.self, forKey: .caption)
        url     = try values.decode(URL.self, forKey: .url)
        fileName = try values.decode(String.self, forKey: .fileName)
    }
    
}

open class QCommentFile: QComment {
    public var caption : String = ""
    
    enum PayloadCodingKeys: String, CodingKey {
        case payload = "payload"
    }
    
    func getCaption() -> String {
        var result : String = ""
//        let model : QCommentFilePayload
        
//        let values = try coder?.container(keyedBy: PayloadCodingKeys.self)
//        result = try values?.decode(QCommentFilePayload.self, forKey: .payload)
//
        return result
    }

    func toStringJSON() {
        
    }
}

//class Demo {
//    let comment = QComment() as! QCommentFile
//
//    func cetak() {
//        print(comment.caption)
//    }
//}
