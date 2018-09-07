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

class NetworkManager: NSObject {
    static let environment  : NetworkEnvironment = .production
    let clientRouter    = Router<APIClient>()
    let roomRouter      = Router<APIRoom>()
    let commentRouter   = Router<APIComment>()
    let userRouter      = Router<APIUser>()
    
    // Download Upload
    private let downloadService = DownloadService()
    // Create downloadsSession here, to set self as delegate
    private lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "downloadSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override init() {
        super.init()
        self.downloadService.downloadsSession = self.downloadsSession
    }
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        QiscusLogger.debugPrint("response code \(response.statusCode)")
        switch response.statusCode {
        case 200...299: return .success
        case 400...499: return .failure(NetworkResponse.clientError.rawValue)
        case 500...599: return .failure(NetworkResponse.serverError.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }

}
// MARK: Client
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
                    let response = ApiResponse.decode(from: responseData)
                    let nonce = QNonce(json: response)
                    completion(nonce, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
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
    ///   - completion: @escaping when success login retrun Optional(UserModel) and Optional(String error message)
    func login(identityToken: String, completion: @escaping (UserModel?, QError?) -> Void) {
        clientRouter.request(.loginRegisterJWT(identityToken: identityToken)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    completion(user, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        QiscusLogger.errorPrint(error as! String)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                    
                    completion(nil,QError(message: errorMessage))
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
    func login(email: String, password: String ,username : String? ,avatarUrl : String?, completion: @escaping (UserModel?, String?) -> Void) {
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
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    completion(user, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
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
    func registerDeviceToken(deviceToken: String, completion: @escaping (Bool, QError?) -> Void) {
        clientRouter.request(.registerDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    
                    completion(true, QError(message: "Success register device token"))
                
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,QError(message: errorMessage))
                }
            }
        }
    }
    
    /// remove device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token to be remove from server
    ///   - completion: @escaping when success remove device token to sdk server returning value bool(success or not) and Optional String(error message)
    func removeDeviceToken(deviceToken: String, completion: @escaping (Bool, QError?) -> Void) {
        clientRouter.request(.removeDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                completion(false, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        completion(false, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    
                    completion(true, QError(message: "Success register device token"))
                    
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(false,QError(message: errorMessage))
                }
            }
        }
    }
    
    
    /// get user profile
    ///
    /// - Parameter completion: @escaping when success get user profile, return Optional(UserModel) and Optional(String error)
    func getProfile(completion: @escaping (UserModel?, String?) -> Void) {
        clientRouter.request(.myProfile) { (data, response, error) in
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
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    completion(user, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil,errorMessage)
                }
            }
        }
    }
    
    /// update user profile
    ///
    /// - Parameters:
    ///   - displayName: user new displayname
    ///   - avatarUrl: user new avatar url
    ///   - completion: @escaping when finish updating user profile return update Optional(UserModel) and Optional(String error message)
    func updateProfile(displayName: String = "", avatarUrl: URL? = nil, completion: @escaping (UserModel?, QError?) -> Void) {
        if displayName.isEmpty && avatarUrl == nil {
            return
        }
        
        clientRouter.request(.updateMyProfile(name: displayName, avatarUrl: avatarUrl?.absoluteString)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    completion(user, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, QError(message: errorMessage))
                }
            }
        }
    }
    
    func sync(lastCommentReceivedId: String, order: String = "", limit: Int = 20, completion: @escaping ([CommentModel]?, String?) -> Void) {
        clientRouter.request(.sync(lastReceivedCommentId: lastCommentReceivedId, order: order, limit: limit)) { (data, response, error) in
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
                    let response = ApiResponse.decode(from: responseData)
                    let comments = CommentApiResponse.comments(from: response)
                    completion(comments, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    
                    completion(nil, errorMessage)
                }
            }
        }
    }
    
    func blockUser(email: String, completion: @escaping (MemberModel?, QError?) -> Void) {
        userRouter.request(.block(email: email)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let member      = UserApiResponse.blockUser(from: response)
                    completion(member, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        QiscusLogger.errorPrint(error as! String)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                    
                    completion(nil,QError(message: errorMessage))
                }
            }
        }
    }
    
    func unblockUser(email: String, completion: @escaping (MemberModel?, QError?) -> Void) {
        userRouter.request(.unblock(email: email)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let member      = UserApiResponse.blockUser(from: response)
                    completion(member, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        QiscusLogger.errorPrint(error as! String)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                    
                    completion(nil,QError(message: errorMessage))
                }
            }
        }
    }
    
    func getBlokedUser(page: Int?, limit: Int?, completion: @escaping ([MemberModel]?, QError?) -> Void) {
        userRouter.request(.listBloked(page: page, limit: limit)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: "Please check your network connection."))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let members     = UserApiResponse.blockedUsers(from: response)
                    completion(members, nil)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        QiscusLogger.errorPrint(error as! String)
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                    
                    completion(nil,QError(message: errorMessage))
                }
            }
        }
    }

    //    MARK: TODO use router to network upload
    func upload(data : Data, filename: String, onSuccess: @escaping (FileModel) -> Void, onError: @escaping (QError) -> Void, progress: @escaping (Double) -> Void) {
        let endpoint = APIClient.upload()
        let request: URLRequest
        
        do {
            request = try NetworkUpload().createRequest(route: endpoint, data: data, filename: filename)
        } catch {
             QiscusLogger.errorPrint(error as! String)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // if response was JSON, then parse it
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        DispatchQueue.main.async {
                            onError(QError(message: NetworkResponse.noData.rawValue))
                        }
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let file     = FileApiResponse.upload(from: response)
                    QiscusLogger.debugPrint("upload \(response)")
                    DispatchQueue.main.async {
                        onSuccess(file)
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        QiscusLogger.errorPrint(error as! String)
                    }
                    DispatchQueue.main.async {
                        onError(QError(message: errorMessage))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func download(url: URL, onSuccess: @escaping (URL) -> Void, onProgress: @escaping (Float) -> Void) {
        let file = FileModel.init(url: url)
        DispatchQueue.global(qos: .background).async {
            // check already in local
            if let localPath = QiscusStorage.shared.fileManager.getlocalPath(from: url) {
                DispatchQueue.main.async {
                    onSuccess(localPath)
                }
            }else {
                self.downloadService.startDownload(file)
            }
        }
        // find progress in active download queue
        for d in downloadService.activeDownloads {
            if d.key == file.url {
                d.value.onProgress = { progress in
                    onProgress(progress)
                }
                d.value.onCompleted = { success in
                    if !success { return }
                    let localPath: URL = QiscusStorage.shared.fileManager.localFilePath(for: d.value.file.url)
                    onSuccess(localPath)
                }
            }
        }
    }
}


// MARK: Download session
extension NetworkManager : URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        if QiscusStorage.shared.fileManager.move(fromURL: sourceURL, to: location) {
            download?.file.downloaded = true
            download?.onCompleted(true)
        }
    }
    
    // Updates progress info
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.totalBytes = totalBytesExpectedToWrite
        download.onProgress(download.progress)
        // 3
        // let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)

    }
}
