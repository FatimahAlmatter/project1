//
//  CommentReplyModel.swift
//  project1
//
//  Created by فاطمه المطر on 16/07/2021.
//

import Foundation

class CommentReplyModel {
    var comment : String?
    var userid : String?
    var commentID : String?
    
    
}

extension CommentReplyModel {
    static func transformCommentReply(dic : [String : Any], key : String) -> CommentReplyModel{
        let comment = CommentReplyModel()
        comment.commentID = key
        comment.comment = dic["comment"] as? String
        comment.userid = dic["userID"] as? String
        return comment
    }
}
