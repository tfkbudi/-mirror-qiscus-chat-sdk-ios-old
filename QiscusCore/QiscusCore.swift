//
//  QiscusCore.swift
//  QiscusCore
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation

public class QiscusCore: NSObject {
    class var bundle:Bundle{
        get{
            let podBundle = Bundle(for: QiscusCore.self)
            if let bundleURL = podBundle.url(forResource: "QiscusCore", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    public static let shared    : QiscusCore            = QiscusCore()
    private static var config    : ConfigManager          = ConfigManager.shared
    static var realtime         : RealtimeManager       = RealtimeManager.shared
    static var eventManager     : QiscusEventManager    = QiscusEventManager.shared
    public static var dataStore : QiscusStorage         = QiscusStorage.shared
    public static var database  : QiscusDatabaseManager = QiscusDatabaseManager.shared
    static var network          : NetworkManager        = NetworkManager()
    public static var delegate  : QiscusCoreDelegate? {
        get {
            return eventManager.delegate
        }
        set {
            eventManager.delegate = newValue
        }
    }
    public static var enableDebugPrint: Bool = false
  
    /// set your app Qiscus APP ID, always set app ID everytime your app lounch. \nAfter login successculy, no need to setup again
    ///
    /// - Parameter WithAppID: Qiscus SDK App ID
    public class func setup(WithAppID id: String) {
        config.appID    = id
        config.server   = ServerConfig(url: URL.init(string: "https://api.qiscus.com/api/v2/mobile")!, realtimeURL: nil, realtimePort: nil)
        realtime.setup(appName: id)
    }
    
    
    /// Connect to qiscus server
    ///
    /// - Parameter delegate: qiscuscore delegate to listen the event
    /// - Returns: true if success connect, please make sure you already login before connect.
    public class func connect(delegate: QiscusConnectionDelegate? = nil) -> Bool {
        // check user login
        if let user = getProfile() {
            // setup configuration
            if let appid = ConfigManager.shared.appID {
                QiscusCore.setup(WithAppID: appid)
            }
            // set delegate
            eventManager.connectionDelegate = delegate
            // connect qiscus realtime server
            realtime.connect(username: user.email, password: user.token)
            return true
        }else {
            return false
        }
    }
    
    /// Setup custom server, when you use Qiscus on premise
    ///
    /// - Parameters:
    ///   - customServer: your custom server host
    ///   - realtimeServer: your qiscus realtime host, without port
    ///   - realtimePort: your qiscus realtime port
    public class func set(customServer: URL, realtimeServer: String?, realtimePort port: Int?) {
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
    public class func login(userID: String, userKey: String, completion: @escaping (UserModel?, String?) -> Void) {
        if config.appID == nil {
            fatalError("You need to set App ID")
        }
        network.login(email: userID, password: userKey, username: nil, avatarUrl: nil) { (results, error) in
            if let user = results {
                // save user in local
                ConfigManager.shared.user = user
                realtime.connect(username: user.email, password: user.token)
            }
            completion(results, error)
        }
    }
    
    /// connect with identityToken, after use nonce and JWT
    ///
    /// - Parameters:
    ///   - token: identity token from your server, when you implement Nonce or JWT
    ///   - completion: The code to be executed once the request has finished, also give a user object and error.
    public class func login(withIdentityToken token: String, completion: @escaping (UserModel?, QError?) -> Void) {
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
        // clear room and comment
        QiscusCore.database.clear()
        // clear config
        ConfigManager.shared.clearConfig()
        // realtime disconnect
        QiscusCore.realtime.disconnect()
        completion(nil)
        
    }
    
    /// check already logined
    ///
    /// - Returns: return true if already login
    public static var isLogined : Bool {
        get {
            return QiscusCore.connect()
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
    
    /// Sync comment
    ///
    /// - Parameters:
    ///   - lastCommentReceivedId: last comment id, to get id you can call QiscusCore.dataStore.getComments().
    ///   - order: "asc" or "desc" only, lowercase. If other than that, it will assumed to "desc"
    ///   - limit: limit number of comment by default 20
    ///   - completion: return object array of comment and return error if exist
    public func sync(lastCommentReceivedId id: String = "", order: String = "", limit: Int = 20, completion: @escaping ([CommentModel]?, QError?) -> Void) {
        if id.isEmpty {
            // get last comment id
            if let comment = QiscusCore.database.comment.all().last {
                QiscusCore.network.sync(lastCommentReceivedId: comment.id, order: order, limit: limit) { (comments, error) in
                    if let message = error {
                        completion(comments,QError.init(message: message))
                    }else {
                        if let results = comments {
                            // Save comment in local
                            QiscusCore.dataStore.saveComments(results)
                        }
                        completion(comments, nil) // success
                    }
                }
            }else {
                completion(nil,QError(message: "please set last comment id"))
            }
        }else {
            QiscusCore.network.sync(lastCommentReceivedId: id, order: order, limit: limit) { (comments, error) in
                if let message = error {
                    completion(comments,QError.init(message: message))
                }else {
                    if let results = comments {
                        // Save comment in local
                        QiscusCore.dataStore.saveComments(results)
                    }
                    completion(comments, nil) // success
                }
            }
        }
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
    
    
    /// Start or stop typing in room,
    ///
    /// - Parameters:
    ///   - value: set true if user start typing, and false when finish
    ///   - roomID: room id where you typing
    ///   - keepTyping: automatic false after n second
    public func isTyping(_ value: Bool, roomID: String, keepTyping: UInt16? = nil) {
        QiscusCore.realtime.isTyping(value, roomID: roomID)
    }
    
    /// Set Online or offline
    ///
    /// - Parameter value: true if user online and false if offline
    public func isOnline(_ value: Bool) {
        QiscusCore.realtime.isOnline(value)
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
    
    /// Get total unreac count by user
    ///
    /// - Parameter completion: number of unread cout for all room
    public func unreadCount(completion: @escaping (Int, QError?) -> Void) {
        QiscusCore.network.unreadCount(completion: completion)
    }
    
    /// Block Qiscus User
    ///
    /// - Parameters:
    ///   - email: qiscus email user
    ///   - completion: Response object user and error if exist
    public func blockUser(email: String, completion: @escaping (MemberModel?, QError?) -> Void) {
        QiscusCore.network.blockUser(email: email, completion: completion)
    }
    
    /// Unblock Qiscus User
    ///
    /// - Parameters:
    ///   - email: qiscus email user
    ///   - completion: Response object user and error if exist
    public func unblockUser(email: String, completion: @escaping (MemberModel?, QError?) -> Void) {
        QiscusCore.network.blockUser(email: email, completion: completion)
    }
    
    /// Get blocked user
    ///
    /// - Parameters:
    ///   - page: page for pagination
    ///   - limit: limit per page
    ///   - completion: Response array of object user and error if exist
    public func listBlocked(page: Int?, limit:Int?, completion: @escaping ([MemberModel]?, QError?) -> Void) {
        QiscusCore.network.getBlokedUser(page: page, limit: limit, completion: completion)
    }
    
    /// Upload to qiscus server
    ///
    /// - Parameters:
    ///   - data: data file to upload
    ///   - filename: file Name
    ///   - onSuccess: return object file model when success
    ///   - onError: return QError
    ///   - progress: progress upload
    public func upload(data : Data, filename: String, onSuccess: @escaping (FileModel) -> Void, onError: @escaping (QError) -> Void, progress: @escaping (Double) -> Void ) {
        QiscusCore.network.upload(data: data, filename: filename, onSuccess: onSuccess, onError: onError, progress: progress)
    }
    
    /// Download
    ///
    /// - Parameters:
    ///   - url: url you want to download
    ///   - onSuccess: resturn local url after success download
    ///   - onProgress: progress download
    public func download(url: URL, onSuccess: @escaping (URL) -> Void, onProgress: @escaping (Float) -> Void) {
        QiscusCore.network.download(url: url, onSuccess: onSuccess, onProgress: onProgress)
    }
}
