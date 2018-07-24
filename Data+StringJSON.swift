//
//  String+Print.swift
//  CocoaAsyncSocket
//
//  Created by Rahardyan Bisma on 24/07/18.
//

import Foundation

extension Data {
    public func toJsonString() -> String {
        guard let jsonString = String(data: self, encoding: .utf8) else {return "invalid json data"}
        return jsonString
    }
}
