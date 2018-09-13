//
//  QiscusDatabase.swift
//  QiscusDatabase
//
//  Created by Qiscus on 12/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

class QiscusDatabase {
    class var bundle:Bundle{
        get{
            let podBundle = Bundle(for: QiscusDatabase.self)
            
            if let bundleURL = podBundle.url(forResource: "QiscusCore", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    
    static let context = PresistentStore.context
   
    static func save() {
        PresistentStore.saveContext()
    }
    
    /// Remove all data from db
    static func clear() {
        // clear all data
    }
}
