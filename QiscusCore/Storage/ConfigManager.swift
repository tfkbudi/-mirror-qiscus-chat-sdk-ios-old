//
//  ConfigManager.swift
//  Pods
//
//  Created by Qiscus on 07/08/18.
//

import Foundation

class ConfigManager : NSObject {
    static let shared = ConfigManager()
    
    var appID   : String? = nil
    var user    : SDKUser? {
        get {
            return loadUser()
        }
        set {
            if let value = newValue {
                saveUser(value)
            }
        }
    }
    var server  : ServerConfig? = nil
    
    private func saveUser(_ data: SDKUser) {
        // save nsuserdefault
    }
    
    private func loadUser() -> SDKUser? {
        return nil
    }
    
}
