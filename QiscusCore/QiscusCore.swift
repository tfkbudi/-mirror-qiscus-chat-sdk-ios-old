//
//  QiscusCore.swift
//  QiscusCore
//
//  Created by Qiscus on 16/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

public class QiscusCore: NSObject {
    
    public static let shared : QiscusCore = QiscusCore()
  
    /// added your app Qiscus APP ID
    ///
    /// - Parameter WithAppID: Qiscus SDK App ID
    public class func setup(WithAppID : String) {
        
    }
    
    // MARK : Auth
    
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
    public class func connect(userID: String, userKey: String, completion: @escaping (SDKUser, Error) -> Void) {
        NetworkManager().login(email: userID, password: userKey, username: nil, avatarUrl: nil) { (results, error) in
            print("results \(results ?? "no result") \nerror: \(error ?? "undefined error")")
        }
    }
    
    public class func disconnect(completionHandler: @escaping () -> Void) {
        
    }
    
    // MARK : Room Management
    
    /// Get or create room with participant
    ///
    /// - Parameters:
    ///   - withParticipants: Qiscus user id.
    ///   - completion: Qiscus Room Object and error if exist. error exm:
    func newRoom(withParticipants: [String], completion: @escaping (QiscusRoom, Error) -> Void) {
        
    }
    
    /// Get
    ///
    /// - Parameters:
    ///   - withID: existing roomID from server or local db.
    ///   - completionHandler: Response Qiscus Room Object and error if exist.
    func getRoom(withID: [String], completion: @escaping (QiscusRoom, Error) -> Void) {
    
    }

}
