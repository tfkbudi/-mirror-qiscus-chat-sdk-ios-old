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
    
    var onProgress : (Double) -> Void = { _ in}
    var onProgressDownload : (Double) -> Void = { _ in}
    
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
    func getNonce(onSuccess: @escaping (QNonce) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.nonce) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let nonce = QNonce(json: response)
                    onSuccess(nonce)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message: errorMessage))
                }
            }
        }
    }
    
    
    /// login
    ///
    /// - Parameters:
    ///   - identityToken: identity token from your server after verify the nonce
    ///   - completion: @escaping when success login retrun Optional(UserModel) and Optional(String error message)
    func login(identityToken: String, onSuccess: @escaping (UserModel) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.loginRegisterJWT(identityToken: identityToken)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    onSuccess(user)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error identityToken Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
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
    func login(email: String, password: String ,username : String? ,avatarUrl : String?, extras: [String:Any]?, onSuccess: @escaping (UserModel) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.loginRegister(user: email, password: password,username: username,avatarUrl: avatarUrl, extras: extras)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    onSuccess(user)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message:errorMessage))
                }
            }
        }
    }
    
    
    /// register device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token for push notification
    ///   - completion: @escaping when success register device token to sdk server returning value bool(success or not) and Optional String(error message)
    func registerDeviceToken(deviceToken: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.registerDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    onSuccess(true)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message: errorMessage))
                }
            }
        }
    }
    
    /// remove device token for notification
    ///
    /// - Parameters:
    ///   - deviceToken: string device token to be remove from server
    ///   - completion: @escaping when success remove device token to sdk server returning value bool(success or not) and Optional String(error message)
    func removeDeviceToken(deviceToken: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.removeDeviceToken(token: deviceToken)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let _ = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    onSuccess(true)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                    } catch {
                        
                    }
                    onError(QError(message: errorMessage))
                }
            }
        }
    }
    
    
    /// get user profile
    ///
    /// - Parameter completion: @escaping when success get user profile, return Optional(UserModel) and Optional(String error)
    func getProfile(onSuccess: @escaping (UserModel) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.myProfile) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message:NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user     = UserApiResponse.user(from: response)
                    onSuccess(user)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error syncEvent Code =\(response.statusCode)\(errorMessage)")
                        onError(QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
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
    func updateProfile(displayName: String = "", avatarUrl: URL? = nil, extras: [String : Any]? = nil,  onSuccess: @escaping (UserModel) -> Void, onError: @escaping (QError) -> Void) {
        if displayName.isEmpty && avatarUrl == nil {
            onError(QError(message: "Please set display name"))
            return
        }
        clientRouter.request(.updateMyProfile(name: displayName, avatarUrl: avatarUrl?.absoluteString, extras: extras)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(from: responseData)
                    let user = UserApiResponse.user(from: response)
                        onSuccess(user)
//                    }else {
//                        onError(QError(message: "Failed to parsing results"))
//                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error updateProfile Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }
    
    func syncEvent(lastId: Int64, onSuccess: @escaping ([SyncEvent]) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.syncEvent(startEventId: lastId)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { onError(QError(message: "Failed to parsing response.")); return}
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response = ApiResponse.decode(syncEvent: responseData)
                    onSuccess(response)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error syncEvent Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }
    
    func sync(lastCommentReceivedId: String, order: String = "", limit: Int = 20, completion: @escaping ([CommentModel]?, String?) -> Void) {
        clientRouter.request(.sync(lastReceivedCommentId: lastCommentReceivedId, order: order, limit: limit)) { (data, response, error) in
            if error != nil {
                completion(nil, error?.localizedDescription ?? "Please check your network connection.")
            }
            if data == nil { completion(nil, "Failed to parsing response."); return }
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
    
    func blockUser(email: String, onSuccess: @escaping (MemberModel) -> Void, onError: @escaping (QError) -> Void) {
        userRouter.request(.block(email: email)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { onError(QError(message: "Failed to parsing response.")); return}
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let member      = UserApiResponse.blockUser(from: response)
                    onSuccess(member)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error blockUser Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }
    
    func unblockUser(email: String, completion: @escaping (MemberModel?, QError?) -> Void) {
        userRouter.request(.unblock(email: email)) { (data, response, error) in
            if error != nil {
                completion(nil, QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { completion(nil, QError(message: "Failed to parsing response.")); return}
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
                        completion(nil, QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error unblockUser Code =\(response.statusCode)\(errorMessage)")
                        completion(nil, QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }
    
    func getBlokedUser(page: Int?, limit: Int?, onSuccess: @escaping ([MemberModel]) -> Void, onError: @escaping (QError) -> Void) {
        userRouter.request(.listBloked(page: page, limit: limit)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { onError(QError(message: "Failed to parsing response.")); return}
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    if let members     = UserApiResponse.blockedUsers(from: response) {
                        onSuccess(members)
                    }else {
                        onError(QError(message: "Result failed to parse"))
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error getBlockUser Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }

    //    MARK: TODO use router to network upload
    func upload(data : Data, filename: String, onSuccess: @escaping (FileModel) -> Void, onError: @escaping (QError) -> Void, progress: @escaping (Double) -> Void) {
        let endpoint = APIClient.upload
        let request: URLRequest
        
        do {
            request = try NetworkUpload().createRequest(route: endpoint, data: data, filename: filename)
        } catch {
             QiscusLogger.errorPrint(error.localizedDescription)
            return
        }
        QiscusLogger.networkLogger(request: request)
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { data, response, error in
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
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error upload Code =\(response.statusCode)\(errorMessage)")
                        DispatchQueue.main.async {
                            onError(QError(message: NetworkResponse.unableToDecode.rawValue))
                        }
                    }
                }
            }
        }
        
        task.resume()
        DispatchQueue.main.async {
            self.onProgress = { progressUpload in
                progress(progressUpload)
            }
        }
        
    }
    
    func download(url: URL, onSuccess: @escaping (URL) -> Void, onProgress: @escaping (Float) -> Void) {
        let file = FileModel.init(url: url)
        DispatchQueue.global(qos: .background).async {
            // check already in local
            if let localPath = QiscusCore.fileManager.getlocalPath(from: url) {
                DispatchQueue.main.async {
                    onSuccess(localPath)
                }
            }else {
                self.downloadService.startDownload(file)
            }
        }
        
        self.onProgressDownload = { progressUpload in
            // find progress in active download queue
            for d in self.downloadService.activeDownloads {
                if d.key == file.url {
                    d.value.onProgress = { progress in
                        onProgress(progress)
                    }
                    d.value.onCompleted = { success in
                        if !success { return }
                        let localPath: URL = QiscusCore.fileManager.localFilePath(for: d.value.file.url)
                        onSuccess(localPath)
                    }
                }
            }
        }
  
    }
    
    func getUsers(limit : Int?, page: Int?, querySearch: String?, onSuccess: @escaping ([MemberModel], Meta) -> Void, onError: @escaping (QError) -> Void) {
        userRouter.request(.getUsers(page: page, limit: limit, querySearch: querySearch)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { onError(QError(message: "Failed to parsing response.")); return}
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    let meta        = UserApiResponse.meta(from: response)
                    if let members     = UserApiResponse.allUser(from: response) {
                        onSuccess(members, meta)
                    }else {
                        onError(QError(message: "Result failed to parse"))
                    }
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error getUsers Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
                }
            }
        }
    }
    
    func event_report(moduleName: String, event: String, message: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (QError) -> Void) {
        clientRouter.request(.eventReport(moduleName: moduleName, event: event, message: message)) { (data, response, error) in
            if error != nil {
                onError(QError(message: error?.localizedDescription ?? "Please check your network connection."))
            }
            if data == nil { onError(QError(message: "Failed to parsing response.")); return}
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        onError(QError(message: NetworkResponse.noData.rawValue))
                        return
                    }
                    let response    = ApiResponse.decode(from: responseData)
                    onSuccess(true)
                case .failure(let errorMessage):
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        QiscusLogger.errorPrint("json: \(jsondata)")
                        onError(QError(message: "json: \(jsondata)"))
                    } catch {
                        QiscusLogger.errorPrint("Error blockUser Code =\(response.statusCode)\(errorMessage)")
                        onError( QError(message: NetworkResponse.unableToDecode.rawValue))
                    }
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
        if QiscusCore.fileManager.move(fromURL: sourceURL, to: location) {
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
        DispatchQueue.main.async {
            self.onProgressDownload(Double(download.progress))
        }

    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64){
        
        let uploadProgress: Double = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.onProgress(uploadProgress)
        }
        
    }
    
}
