//
//  QiscusLogger.swift
//  QiscusCore
//
//  Created by Rahardyan Bisma on 24/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

class QiscusLogger {
    static func debugPrint(_ text: String) {
        if QiscusCore.enableDebugPrint {
            print("[QiscusCore] \(text)")
        }
    }
    
    static func errorPrint(_ text: String) {
        print("[QiscusCore] Error: \(text)")
    }
}
