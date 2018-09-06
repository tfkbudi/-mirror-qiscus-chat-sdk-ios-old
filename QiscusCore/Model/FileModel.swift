//
//  FileModel.swift
//  QiscusCore
//
//  Created by Qiscus on 06/09/18.
//

/**
 file =         {
     name = "upload1.jpg";
     pages = 1;
     size = 2128079;
     url = "https://upload1.jpg";
 }
 */

import SwiftyJSON

public struct FileModel {
    public var name : String
    public var size : Int
    public var url  : URL

    init(json: JSON) {
        url     = json["url"].url ?? URL(string: "http://")!
        name    = json["name"].stringValue
        size    = json["size"].intValue
    }
}
