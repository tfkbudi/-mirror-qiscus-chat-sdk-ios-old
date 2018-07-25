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
    static var customURL : URL? = nil
    public static var enableDebugPrint: Bool = false
    public static var networkManager: NetworkManager = NetworkManager()
  
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
        
        NetworkManager().getNonce(completion: completion)
    }
    
    /// SDK Connect with userId. The handler to be called once the request has finished.
    ///
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - parameter completion          : The code to be executed once the request has finished, also give a user object and error.
    ///
    public class func connect(userID: String, completion: @escaping (SDKUser, Error) -> Void) {
        
    }
    
    /// SDK Connect with userId and passkey. The handler to be called once the request has finished.
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - userKey                       : user password
    /// - parameter completion          : The code to be executed once the request has finished, also give a user object and error.
    ///
    public class func connect(userID: String, userKey: String, completion: @escaping (QUser?, String?) -> Void) {
        NetworkManager().login(email: userID, password: userKey, username: nil, avatarUrl: nil) { (results, error) in
            completion(results, error)
        }
    }
    
    public class func disconnect(completionHandler: @escaping () -> Void) {
        
    }
}
