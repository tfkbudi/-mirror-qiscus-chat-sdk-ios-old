//
//  QiscusConfig.swift
//  QiscusCore
//
//  Created by Qiscus on 07/08/18.
//

import Foundation

public struct QiscusServer {
    public let url : URL
    public let realtimeURL : String?
    public let realtimePort : UInt16?
    
    public init (url: URL, realtimeURL: String?, realtimePort: UInt16?) {
        self.url            = url + "/api/v2/sdk"
        self.realtimeURL    = realtimeURL
        self.realtimePort   = realtimePort
    }
}
