//
//  EndpointComment.swift
//  QiscusCore
//
//  Created by Qiscus on 13/08/18.
//

import Foundation

// MARK: Comment API
internal enum APIComment {
    case postComment(topicId: String, type: String, message: String, payload: [String:Any]?, extras: String?, uniqueTempId: String?)
    case loadComment(topicId: String, lastCommentId: Int?, timestamp: String?, after: Bool?, limit: Int?)
    case delete(commentUniqueId: [String], type: DeleteType)
    case updateStatus(roomId: String,lastCommentReadId: String?, lastCommentReceivedId: String?)
    case clear(roomChannelIds: [String])
    /// Search comment on server
    case search(keyword: String, roomID: String?, lastCommentID: Int?)
    case statusComment(id: String)
}

extension APIComment : EndPoint {
    var baseURL: URL {
        return BASEURL
    }
    
    var path: String {
        switch self {
        case .postComment:
            return "/post_comment"
        case .loadComment:
            return "/load_comments"
        case .delete( _):
            return "/delete_messages"
        case .updateStatus( _, _, _):
            return "/update_comment_status"
        case .clear( _):
            return "/clear_room_messages"
        case .search:
            return "/search_messages"
        case .statusComment(_):
            return "/comment_receipt"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .loadComment, .statusComment(_):
            return .get
        case .postComment, .updateStatus, .search( _, _, _):
            return .post
        case .delete, .clear( _):
            return .delete
        }
    }
    
    var header: HTTPHeaders? {
        return HEADERS
    }
    
    var task: HTTPTask {
        switch self {
        case .postComment(let topicId, let type, let message, let payload, let extras, let uniqueTempId):
            var params = [
                "token"                      : AUTHTOKEN,
                "topic_id"                   : topicId,
                "type"                       : type,
                "comment"                    : message
                ] as [String : Any]
            if let payloadParams = payload {
                params["payload"] = payloadParams
            }
            if let extrasParams = extras {
                if !extrasParams.isEmpty {
                    params["extras"] = extrasParams
                }
            }
            if let uniquetempid = uniqueTempId {
                params["unique_temp_id"] = uniquetempid
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .loadComment(let topicId, let lastCommentId ,let timestamp,let after,let limit):
            var params = [
                "token"                      : AUTHTOKEN,
                "topic_id"                   : topicId
                ] as [String : Any]
            
            if let lastcommentid = lastCommentId {
                params["last_comment_id"] = lastcommentid
            }
            if let timestmp = timestamp {
                params["timestamp"] = timestmp
            }
            if let aftr = after {
                params["after"] = aftr
            }
            if let limt = limit {
                params["limit"] = limt
            }
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: params)
        case .delete(let id, let type):
            var params = [
                "token"                     : AUTHTOKEN,
                "unique_ids"                : id
                ] as [String : Any]
            if type == .forEveryone {
                params["is_delete_for_everyone"] = true
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .updateStatus(let roomId,let lastCommentReadId,let lastCommentReceivedId):
            var params = [
                "token"                     : AUTHTOKEN,
                "room_id"                   : roomId
                ] as [String : Any]
            
            if let lastcommentreadid = lastCommentReadId {
                params["last_comment_read_id"] = lastcommentreadid
            }
            
            if let lastcommentreceivedid = lastCommentReceivedId {
                params["last_comment_received_id"] = lastcommentreceivedid
            }
            
            return .requestParameters(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .clear(let roomChannelIds):
            let params = [
                "token"                      : AUTHTOKEN,
                "room_channel_ids"           : roomChannelIds
                ] as [String : Any]
            return .requestParameters(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .search(let keyword, let roomID, let lastCommentID):
            var params = [
                "token"                     : AUTHTOKEN,
                "query"                     : keyword,
            ] as [String : Any]
            if let id = roomID {
                params["room_id"] = id
            }
            if let commentID = lastCommentID {
                params["last_comment_id"] = commentID
            }
            return .requestParameters(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: nil)
        case .statusComment(let id):
            let params = [
                "token"                     : AUTHTOKEN,
                "comment_id"                : id,
                ] as [String : Any]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: params)
        }
    }
}
