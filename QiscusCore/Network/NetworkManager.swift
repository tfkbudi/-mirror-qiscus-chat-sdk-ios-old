//
//  NetworkManager.swift
//  QiscusCore
//
//  Created by Qiscus on 18/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit

enum NetworkResponse:String {
    case success
    case clientError = "Client Error."
    case serverError = "Server Error."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "Response not JSON or undefined."
}

enum Result<String>{
    case success
    case failure(String)
}

enum NetworkEnvironment : String {
    case production
    case staging
}

// TODO remove public, this class should not be accessed from outside qiscusCore
public class NetworkManager: NSObject {
    static let environment  : NetworkEnvironment = .production
    static let APPID        : String = ""
    static var token        : String = ""
    static var userEmail    : String = ""
    let clientRouter    = Router<APIClient>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        print("response code \(response.statusCode)")
        switch response.statusCode {
        case 200...299: return .success
        case 400...499: return .failure(NetworkResponse.clientError.rawValue)
        case 500...599: return .failure(NetworkResponse.serverError.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

// MARK : Client
extension NetworkManager {
    /// get nonce for JWT authentication
    ///
    /// - Parameter completion: @ecaping on getNonce request done return Optional(QNonce) and Optional(Error message)
    func getNonce(completion: @escaping (QNonce?, String?)->Void) {
        clientRouter.request(.nonce) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(NonceApiResponse.self, from: responseData)
                        completion(apiResponse.results, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    
    /// login
    ///
    /// - Parameters:
    ///   - identityToken: identity token from your server after verify the nonce
    ///   - completion: @escaping when success login retrun Optional(QUser) and Optional(String error message)
    func login(identityToken: String, completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.loginRegisterJWT(identityToken: identityToken)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(UserApiResponse.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    /// login
    ///
    /// - Parameters:
    ///   - email: username or email identifier
    ///   - password: user password to login to qiscus sdk
    ///   - username: user display name
    ///   - avatarUrl: user avatar url
    ///   - completion: @escaping on 
    func login(email: String, password: String ,username : String? ,avatarUrl : String?, completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.loginRegister(user: email, password: password,username: username,avatarUrl: avatarUrl)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(UserApiResponse.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    
    /// register device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token for push notification
    ///   - completion: @escaping when success register device token to sdk server returning value bool(success or not) and Optional String(error message)
    func registerDeviceToken(deviceToken: String, completion: @escaping (Bool, String) -> Void) {
        clientRouter.request(.registerDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    completion(true, "Success register device token")
                
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,errorMessage)
                }
            }
        }
    }
    
    /// remove device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token to be remove from server
    ///   - completion: @escaping when success remove device token to sdk server returning value bool(success or not) and Optional String(error message)
    func removeDeviceToken(deviceToken: String, completion: @escaping (Bool, String) -> Void) {
        clientRouter.request(.removeDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    completion(true, "Success register device token")
                    
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,errorMessage)
                }
            }
        }
    }
    
    
    /// update user profile
    ///
    /// - Parameters:
    ///   - displayName: user new displayname
    ///   - avatarUrl: user new avatar url
    ///   - completion: @escaping when finish updating user profile return update Optional(QUser) and Optional(String error message)
    public func updateProfile(displayName: String, avatarUrl: String, completion: @escaping (QUser?, String?) -> Void) {
        clientRouter.request(.updateMyProfile(name: displayName, avatarUrl: avatarUrl)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(UserApiResponse.self, from: responseData)
                        NetworkManager.token = apiResponse.results.user.token
                        NetworkManager.userEmail = apiResponse.results.user.email
                        completion(apiResponse.results.user, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let errorMessage):
                    // MARK: Todo print error message
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
}
