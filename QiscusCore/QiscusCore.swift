//
//  QiscusCore.swift
//  QiscusCore
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

class QiscusCore: NSObject {
    
    
    /// added your app Qiscus APP ID
    ///
    /// - Parameter WithAppID: Qiscus SDK App ID
    class func init(WithAppID : String) {
        
    }
    
    /// SDK Connect with userId. The handler to be called once the request has finished.
    ///
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - parameter completionHandler   : The code to be executed once the request has finished, also give a user object and error.
    ///
    class func connect(userID: String, completionHandler: @escaping (SDKUser, Error) -> Void) {
        
    }
    
    /// SDK Connect with userId and passkey. The handler to be called once the request has finished.
    /// - parameter userID              : must be unique per appid, exm: email, phonenumber, udid.
    /// - userKey                       : user password
    /// - parameter completionHandler   : The code to be executed once the request has finished, also give a user object and error.
    ///
    class func connect(userID: String, userKey: String, completionHandler: @escaping (SDKUser, Error) -> Void) {
        
    }
    
    class func disconnect(completionHandler: @escaping () -> Void) {
        
    }
    
}
