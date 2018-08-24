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
    var appID   : String? {
        get {
            let storage = UserDefaults.standard
            return storage.string(forKey: "qiscuskey") ?? nil
        }
        set {
            guard let id = newValue else { return }
            let storage = UserDefaults.standard
            storage.set(id, forKey: "qiscuskey")
        }
    }
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
        return prefix + name + "userdata"
    }
    
    private func saveUser(_ data: UserModel) {
        // save in file
        let defaults = UserDefaults.standard
        defaults.set(data.id, forKey: filename("id"))
        defaults.set(data.username, forKey: filename("username"))
        defaults.set(data.email, forKey: filename("email"))
        defaults.set(data.token, forKey: filename("token"))
        defaults.set(data.rtKey, forKey: filename("rtKey"))
        defaults.set(data.pnIosConfigured, forKey: filename("pnIosConfigured"))
        defaults.set(data.lastSyncEventId, forKey: filename("lastSyncEventId"))
        defaults.set(data.lastCommentId, forKey: filename("lastCommentId"))
        defaults.set(data.avatarUrl, forKey: filename("avatarUrl"))
    }
    
    private func loadUser() -> UserModel? {
        // save in cache
        let storage = UserDefaults.standard
        if let token = storage.string(forKey: filename("token")) {
            if token.isEmpty { return nil }
            var user = UserModel()
            user.token      = token
            user.id         = storage.string(forKey: filename("id")) ?? ""
            user.email      = storage.string(forKey: filename("email")) ?? ""
            user.username   = storage.string(forKey: filename("username")) ?? ""
            user.avatarUrl  = storage.url(forKey: filename("avatarUrl")) ?? URL(string: "http://")!
            user.lastSyncEventId    = Int64(storage.integer(forKey: filename("username")))
            self.userCache  = user
            return user
        }else {
            return nil
        }
    }
    
    func clearConfig() {
        // remove file user
        //Storage.removeFile(filename("userdata"), in: .document)
        self.userCache = nil
    }
}
