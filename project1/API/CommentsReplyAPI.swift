//
//  CommentsReplyAPI.swift
//  project1
//
//  Created by فاطمه المطر on 17/07/2021.
//

import Foundation
import FirebaseDatabase

class CommentsReplyAPI {
    var commentReply_ref = Database.database().reference().child("CommentsReply")
    
    func observeCommentFromDB(snapshot : String , completed : @escaping (CommentReplyModel) -> Void){
        commentReply_ref.child(snapshot).observeSingleEvent(of: DataEventType.value) { (snapshotKey : DataSnapshot) in
            if let dic = snapshotKey.value as? [String : Any] {
                let newComment = CommentReplyModel.transformCommentReply(dic: dic, key: snapshot)
                completed(newComment)
            }
        }
    }
}
