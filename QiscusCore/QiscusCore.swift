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
    
    // MARK : Auth
    
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
    
    // MARK : Room Management
    
    /// Get or create room with participant
    ///
    /// - Parameters:
    ///   - withParticipants: Qiscus user id.
    ///   - completionHandler: Qiscus Room Object and error if exist. error exm:
    class func newRoom(withParticipants: [String], completionHandler: @escaping (QiscusRoom, Error) -> Void)) {
        
    }
    
    
    /// Get
    ///
    /// - Parameters:
    ///   - withID: existing roomID from server or local db.
    ///   - completionHandler: Response Qiscus Room Object and error if exist.
    class func getRoom(withID: [String], completionHandler: @escaping (QiscusRoom, Error) -> Void)) {
    
    }
    
    class func newRoom(withParticipants: [String], completionHandler: @escaping (QiscusRoom, Error) -> Void)) {
    
    }
    
    
    // MARK : Utilities
    
}
