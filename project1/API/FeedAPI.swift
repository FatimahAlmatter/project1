//
//  FeedAPI.swift
//  project1
//
//  Created by فاطمه المطر on 02/08/2021.
//

import Foundation
import FirebaseDatabase

class FeedAPI {
    var feed_ref = Database.database().reference().child("Feed")
    
    func observeFeedPost(user : String , completion : @escaping (PostModel)->Void )  {
        feed_ref.child(user).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            API.post.observePostWithID(withID: key) { (post) in
                completion(post)
            }
        }
    }
    
    func observeRemovedPostsFromFeed(userid : String , completion : @escaping (PostModel)->Void ) {
        feed_ref.child(userid).observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            API.post.observePostWithID(withID: key) { (post) in
                completion(post)
            }
            
        }
    }
}
