//
//  CommentModel.swift
//  project1
//
//  Created by فاطمه المطر on 12/07/2021.
//

import Foundation

class CommentModel {
    var comment : String?
    var userid : String?
    var commentID : String?
    
    
}

extension CommentModel {
    static func transformComment(dic : [String : Any], key : String) -> CommentModel{
        let comment = CommentModel()
        comment.commentID = key
        comment.comment = dic["comment"] as? String
        comment.userid = dic["userID"] as? String
        return comment
    }
}
