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
    var syncEventId : Int64 {
        get {
            return self.getSyncEventId()
        }
        set {
            self.setSyncEventId(newValue)
        }
    }
    var syncId : String {
        get {
            return self.getSyncId()
        }
        set {
            self.setSyncId(newValue)
        }
    }
    
    var server      : QiscusServer?     = nil
    var syncInterval : TimeInterval     = 10.0
    
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
//        defaults.set(data.pnIosConfigured, forKey: filename("pnIosConfigured"))
//        defaults.set(data.lastSyncEventId, forKey: filename("lastSyncEventId"))
//        defaults.set(data.lastCommentId, forKey: filename("lastCommentId"))
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
//            user.lastSyncEventId    = Int64(storage.integer(forKey: filename("username")))
            self.userCache  = user
            return user
        }else {
            return nil
        }
    }
    
    private func setSyncId(_ id: String) {
        // save in file
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: filename("syncId"))
    }
    
    private func getSyncId() -> String {
        // save in file
        let defaults = UserDefaults.standard
        return defaults.string(forKey: filename("syncId")) ?? ""
    }
    
    private func setSyncEventId(_ id: Int64) {
        // save in file
        let defaults = UserDefaults.standard
        let current = self.getSyncEventId()
        if id > current {
            defaults.set(id, forKey: filename("syncEventId"))
        }
    }
    
    private func getSyncEventId() -> Int64 {
        // save in file
        let defaults = UserDefaults.standard
        return Int64(defaults.integer(forKey: filename("syncEventId")))
    }
    
    func clearConfig() {
        // remove file user
        let storage = UserDefaults.standard
        storage.removeObject(forKey: filename("id"))
        storage.removeObject(forKey: filename("token"))
        storage.removeObject(forKey: filename("username"))
        storage.removeObject(forKey: filename("email"))
        storage.removeObject(forKey: filename("rtKey"))
        storage.removeObject(forKey: filename("avatarUrl"))
        storage.removeObject(forKey: filename("syncEventId"))
//        storage.removeObject(forKey: filename("lastCommentId"))
        self.userCache = nil
    }
}
