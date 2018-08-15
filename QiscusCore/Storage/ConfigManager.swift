//
//  ConfigManager.swift
//  Pods
//
//  Created by Qiscus on 07/08/18.
//

import Foundation

class ConfigManager : NSObject {
    static let shared = ConfigManager()
    private let prefix = "qcu_"
    fileprivate var userCache : UserModel? = nil
    var appID   : String? = nil
    var user    : UserModel? {
        get {
            if let user = userCache {
                return user
            }else {
                return loadUser()
            }
        }
        set {
            if let value = newValue {
                saveUser(value)
            }
        }
    }
    var server  : ServerConfig? = nil
    
    fileprivate func filename(_ name: String) -> String {
        return prefix + name + ".json"
    }
    
    private func saveUser(_ data: UserModel) {
        // save in file
        Storage.save(data, to: .document, as: filename("userdata"))
    }
    
    private func loadUser() -> UserModel? {
        // save in cache
        let user = Storage.find(filename("userdata"), in: .document, as: UserModel.self)
        self.userCache = user
        return user
    }
    
}
