//
//  QiscusCore.swift
//  QiscusCore
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

public class QiscusCore: NSObject {
    
    public static let shared : QiscusCore = QiscusCore()
    private static var config : ConfigManager = ConfigManager.shared
    private static var realtime : RealtimeManager?
    static var network : NetworkManager = NetworkManager()
    public static var enableDebugPrint: Bool = false
  
    /// set your app Qiscus APP ID, always set app ID everytime your app lounch
    ///
    /// - Parameter WithAppID: Qiscus SDK App ID
    public class func setup(WithAppID id: String) {
        config.appID    = id
        config.server   = ServerConfig(url: URL.init(string: "https://api.qiscus.com/api/v2/mobile")!, realtimeURL: nil, realtimePort: nil)
        realtime        = RealtimeManager.init(appName: id)
        QiscusCore.connect()
    }
    
    static func connect() {
        // check user login
        if let user = getProfile() {
            realtime?.connect(username: user.email, password: user.token)
        }
    }
    
    /// Setup custom server, when you use Qiscus on premise
    ///
    /// - Parameters:
    ///   - customServer: your custom server host
    ///   - realtimeServer: your qiscus realtime host, without port
    ///   - realtimePort: your qiscus realtime port
    public class func set(customServer: URL, realtimeServer: String, realtimePort port: Int) {
        config.server = ServerConfig(url: customServer, realtimeURL: realtimeServer, realtimePort: port)
    }
    
    // MARK: Auth

    /// Get Nonce from SDK server. use when login with JWT
    ///
    /// - Parameter completion: @escaping with Optional(QNonce) and String Optional(error)
    public class func getNonce(completion: @escaping (QNonce?, String?) -> Void) {
        if config.appID == nil {
            fatalError("You need to set App ID")
        }
        network.getNonce(completion: completion)
    }
    
    /// SDK Connect with userId and passkey. The handler to be called once the request has finished.
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - userKey                       : user password
    /// - parameter completion          : The code to be executed once the request has finished, also give a user object and error.
    ///
    public class func connect(userID: String, userKey: String, completion: @escaping (UserModel?, String?) -> Void) {
        if config.appID == nil {
            fatalError("You need to set App ID")
        }
        network.login(email: userID, password: userKey, username: nil, avatarUrl: nil) { (results, error) in
            if let user = results, let client = realtime {
                // save user in local
                ConfigManager.shared.user = user
                client.connect(username: user.email, password: user.token)
            }
            completion(results, error)
        }
    }
    
    /// connect with identityToken, after use nonce and JWT
    ///
    /// - Parameters:
    ///   - token: identity token from your server, when you implement Nonce or JWT
    ///   - completion: The code to be executed once the request has finished, also give a user object and error.
    public class func connect(withIdentityToken token: String, completion: @escaping (UserModel?, QError?) -> Void) {
        if config.appID == nil {
            fatalError("You need to set App ID")
        }
        network.login(identityToken: token) { (results, error) in
            if let user = results {
                // save user in local
                ConfigManager.shared.user = user
            }
            completion(results, error)
        }
    }
    
    /// Disconnect or logout
    ///
    /// - Parameter completionHandler: The code to be executed once the request has finished, also give a user object and error.
    public static func logout(completion: @escaping (QError?) -> Void) {
        
    }
    
    /// check already logined
    ///
    /// - Returns: return true if already login
    public static var isLogined : Bool {
        get {
            return (ConfigManager.shared.user != nil)
        }
    }
    
    /// Register device token Apns or Pushkit
    ///
    /// - Parameters:
    ///   - deviceToken: device token
    ///   - completion: The code to be executed once the request has finished
    public func register(deviceToken : String, completion: @escaping (Bool, QError?) -> Void) {
        QiscusCore.network.registerDeviceToken(deviceToken: deviceToken, completion: completion)
    }
    
    /// Remove device token
    ///
    /// - Parameters:
    ///   - deviceToken: device token
    ///   - completion: The code to be executed once the request has finished
    public func remove(deviceToken : String, completion: @escaping (Bool, QError?) -> Void) {
        QiscusCore.network.removeDeviceToken(deviceToken: deviceToken, completion: completion)
    }
    
    // MARK: User Profile
    
    /// get qiscus user from local storage
    ///
    /// - Returns: return nil when client not logined, and return object user when already logined
    public static func getProfile() -> UserModel? {
        return ConfigManager.shared.user
    }
    
    /// Get Profile from server
    ///
    /// - Parameter completion: The code to be executed once the request has finished
    public func getProfile(completion: @escaping (UserModel?, QError?) -> Void) {
        QiscusCore.network.getProfile { (user, error) in
            if let profile = user{
                completion(profile,nil)
            }
            if let message = error {
                completion(nil,QError.init(message: message))
            }
        }
    }
    
    /// Update user profile
    ///
    /// - Parameters:
    ///   - displayName: nick name
    ///   - url: user avatar url
    ///   - completion: The code to be executed once the request has finished
    public func updateProfile(displayName: String = "", avatarUrl url: URL? = nil, completion: @escaping (UserModel?, QError?) -> Void) {
        QiscusCore.network.updateProfile(displayName: displayName, avatarUrl: url, completion: completion)
    }
    
    public func unreadCount(completion: @escaping (Int, QError?) -> Void) {
        QiscusCore.network.unreadCount(completion: completion)
    }
}

public enum RoomType: String {
    case Single = "single"
    case Group = "group"
    case PublicChannel = "public_channel"
}
