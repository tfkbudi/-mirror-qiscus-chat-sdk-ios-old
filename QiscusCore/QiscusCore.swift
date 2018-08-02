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
    
    static var appId: String = ""
    var customURL : Int? = nil
    public static var network : NetworkManager = NetworkManager()
    public static var enableDebugPrint: Bool = false
  
    /// added your app Qiscus APP ID
    ///
    /// - Parameter WithAppID: Qiscus SDK App ID
    public class func setup(WithAppID appId: String, customURL: URL? = nil) {
        self.appId = appId
        //self.customURL = customURL
        
    }
    
    // MARK: Auth

    /// Get Nonce from SDK server. use when login with JWT
    ///
    /// - Parameter completion: @escaping with Optional(QNonce) and String Optional(error)
    public class func getNonce(completion: @escaping (QNonce?, String?) -> Void) {
        if self.appId.isEmpty {
             QiscusLogger.errorPrint("please call setup() first")
            return
        }
        network.getNonce(completion: completion)
    }
    
    /// SDK Connect with userId and passkey. The handler to be called once the request has finished.
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - userKey                       : user password
    /// - parameter completion          : The code to be executed once the request has finished, also give a user object and error.
    ///
    public class func connect(userID: String, userKey: String, completion: @escaping (QUser?, String?) -> Void) {
        network.login(email: userID, password: userKey, username: nil, avatarUrl: nil) { (results, error) in
            completion(results, error)
        }
    }
    
    /// connect with identityToken, after use nonce and JWT
    ///
    /// - Parameters:
    ///   - token: identity token from your server, when you implement Nonce or JWT
    ///   - completion: The code to be executed once the request has finished, also give a user object and error.
    public class func connect(withIdentityToken token: String, completion: @escaping (QUser?, String?) -> Void) {
        network.login(identityToken: token, completion: completion)
    }
    
    /// Disconnect or logout
    ///
    /// - Parameter completionHandler: The code to be executed once the request has finished, also give a user object and error.
    public class func disconnect(completion: @escaping (Error?) -> Void) {
        
    }
    
}

public enum RoomType: String {
    case Single = "single"
    case Group = "group"
    case PublicChannel = "public_channel"
}
