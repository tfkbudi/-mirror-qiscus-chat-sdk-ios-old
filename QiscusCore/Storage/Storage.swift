//
//  Storage.swift
//  QiscusCore
//
//  Created by Qiscus on 08/08/18.
//

import Foundation

class Storage {
    
    enum Directory {
        // should be store in <Application_Home>/Documents
        case document
        // should be store in <Application_Home>/Library/Caches directory
        case caches
    }
    
    /// Get url by time of directory
    ///
    /// - Parameter dir: directory type, document or cache
    /// - Returns: URL base on type of directory
    static fileprivate func getURL(by dir: Directory) -> URL {
        var pathDirectory : FileManager.SearchPathDirectory
        
        switch dir {
        case .document:
            pathDirectory = .documentDirectory
        case .caches:
            pathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: pathDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            return url
        }else {
            fatalError("Could not be found directory")
        }
    }
    
    /// Save Codable object in document directory
    ///
    /// - Parameters:
    ///   - object: Codable object
    ///   - directory: where you want to save file document dir or cache
    ///   - fileName: file name
    static func save<T: Codable>(_ object: T, to directory: Directory, as filename: String) {
//        let throttler = Throttler.init(seconds: 5)
//        throttler.throttle {
            let url = getURL(by: directory).appendingPathComponent(filename, isDirectory: false)
            
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(object)
                // check if file exist then remove
                if fileExist(filename, in: directory) {
                    try FileManager.default.removeItem(at: url)
                }
                // create new file
                FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        //}
    }
    
    /// find file in directory
    ///
    /// - Parameters:
    ///   - filename: filename with extention
    ///   - in: type of directory document or cache
    ///   - type: codable object
    /// - Returns: codable object
    static func find<T: Codable>(_ filename: String, in dir: Directory, as type: T.Type) -> T? {
        let url = getURL(by: dir).appendingPathComponent(filename, isDirectory: false)
        
        if !fileExist(filename, in: dir) {
            QiscusLogger.errorPrint("File in this path \(url.path) not exist")
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
//                let user = try decoder.decode(UserModel.self, from: data)
//                print("name : \(user.email)")
                let model = try decoder.decode(type, from: data)
                return model
                
            } catch {
                QiscusLogger.errorPrint(error.localizedDescription)
                return nil
            }
        }else {
            QiscusLogger.errorPrint("File in this path \(url.path) not exist")
            return nil
        }
    }
    
    /// Check file exist
    ///
    /// - Parameters:
    ///   - filename: filename with extention
    ///   - in: type of directory document or cache
    /// - Returns: true if file exist
    static func fileExist(_ filename: String, in directory: Directory) -> Bool {
        let url = getURL(by: directory).appendingPathComponent(filename, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// remove file in directory where file exist
    ///
    /// - Parameters:
    ///   - filename: filename with extention
    ///   - directory: type of directory document or cache
    static func removeFile(_ filename: String, in directory: Directory) {
        let url = getURL(by: directory).appendingPathComponent(filename, isDirectory: false)
        
        if fileExist(filename, in: directory) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                QiscusLogger.errorPrint("File in this path \(url.path) can't be remove")
            }
        }
    }
}
