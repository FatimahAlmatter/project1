//
//  PostAPI.swift
//  project1
//
//  Created by فاطمه المطر on 17/07/2021.
//

import Foundation
import FirebaseDatabase

class PostAPI {
    var post_ref = Database.database().reference().child("Posts")
    
    func observePostsFromDatabase(completed: @escaping (PostModel) -> Void){
        post_ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let dic = snapshot.value as? [String : Any]{
                let post = PostModel.transformPostModel(dic: dic, key: snapshot.key)
                completed(post)
            }
        }
    }
    
    
    //i هالطريقه خاصه لاستدعاء البوست عن طريق الآي دي
    func observePostWithID(withID id : String , completed: @escaping (PostModel) -> Void) {
        post_ref.child(id).observeSingleEvent(of: DataEventType.value) { (snapshot : DataSnapshot) in
            if let dic = snapshot.value as? [String : Any] {
                let post = PostModel.transformPostModel(dic: dic, key: snapshot.key)
                completed(post)
            }
            
        }
    }
    
    func observeLikes(postID : String , IfLikeSuccess: @escaping (PostModel)->Void , IfLikeError: @escaping (_ ErrorMessage : String)->Void){
        let ref = post_ref.child(postID)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String: AnyObject],
               let uid = API.user.currentUser?.uid {
                var likes: [String: Bool]
                likes = post["likes"] as? [String: Bool] ?? [:]
                var likesCount = post["likesCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unlike the post and remove self from likes
                    likesCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    // Like the post and add self to likes
                    likesCount += 1
                    likes[uid] = true
                }
                post["likesCount"] = likesCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
            if let dic = snapshot?.value as? [String : Any] {
                let likeSnapshot = PostModel.transformPostModel(dic: dic, key: snapshot!.key)
                IfLikeSuccess(likeSnapshot)
                
            }
            
        }
    }
    
    func observeTopLikedPosts(completion : @escaping (PostModel)->Void) {
        post_ref.queryOrdered(byChild: "likesCount").observeSingleEvent(of: .value) { (snapshot) in
            //put the more liked post at the top of collection 
            let postSnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            postSnapshot.forEach { (child) in
                if let dic = child.value as? [String : Any] {
                    let post = PostModel.transformPostModel(dic: dic, key: child.key)
                    completion(post)
                }
            }
        }
    }
}
