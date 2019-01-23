//
//  CommentInfo.swift
//  QiscusCore
//
//  Created by Qiscus on 23/01/19.
//

import Foundation

public struct CommentInfo {
    public var comment = CommentModel()
    public var deliveredUser = [MemberInfoModel]()
    public var readUser = [MemberInfoModel]()
    public var pendingUser = [MemberInfoModel]()
    
}


