//
//  CommentsAPI.swift
//  project1
//
//  Created by فاطمه المطر on 17/07/2021.
//

import Foundation
import FirebaseDatabase

class CommentsAPI {
    var comments_ref = Database.database().reference().child("Comments")
    
    func observeCommentFromDB(snapshot: String , completed: @escaping (CommentModel) -> Void){
        comments_ref.child(snapshot).observeSingleEvent(of: DataEventType.value) { (snapshotKey : DataSnapshot) in
            
            if let dic = snapshotKey.value as? [String : Any] {
                let newComment = CommentModel.transformComment(dic: dic, key: snapshot)
                
                completed(newComment)
                
            }
        }
    }
}
