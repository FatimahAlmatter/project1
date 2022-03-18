//
//  FollowAPI.swift
//  project1
//
//  Created by فاطمه المطر on 30/07/2021.
//

import Foundation
import FirebaseDatabase

class FollowAPI  {
    var followers_ref = Database.database().reference().child("Followers")
    var following_ref = Database.database().reference().child("Following")

    func follow( user : String) {
        API.myPost.myPost_ref.child(user).observeSingleEvent(of: .value) { (snapshot) in
            if let dic = snapshot.value as? [String : Any] {
                for key in dic.keys {
                    API.feedApi.feed_ref.child(API.user.currentUser!.uid).child(key).setValue(true)
                }
            }
        }
        followers_ref.child(user).child(API.user.currentUser!.uid).setValue(true)
        following_ref.child(API.user.currentUser!.uid).child(user).setValue(true)
    }
    
    func unfollow( user : String) {
        // NSNull to remove the key from list
        followers_ref.child(user).child(API.user.currentUser!.uid).setValue(NSNull())
        following_ref.child(API.user.currentUser!.uid).child(user).setValue(NSNull())
        
        
        //i التالي: لما اسوي انفولو لشخص تنمسح بوستاته من صفة الهوم عندي
        API.myPost.myPost_ref.child(user).observeSingleEvent(of: .value) { (snapshot) in
            if let dic = snapshot.value as? [String : Any] {
                for key in dic.keys {
                    API.feedApi.feed_ref.child(API.user.currentUser!.uid).child(key).removeValue()

                }
            }
        }

    }
    
    
    func isFollowing(user : String , completion : @escaping (Bool)->Void){
        followers_ref.child(user).child(API.user.currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completion(false)
            }else{
                completion(true)
            }
        }
    }
     
    func observeNumberOfFollowers(userID : String , completion : @escaping (Int)->Void) {
        followers_ref.child(userID).observe(.value) { (snapshot) in
            let count = snapshot.childrenCount
            completion(Int(count))
        }
    }
    
    func observeNumberOfFollowing(userID : String , completion : @escaping (Int)->Void) {
        following_ref.child(userID).observe(.value) { (snapshot) in
            let count = snapshot.childrenCount
            completion(Int(count))
        }
    }
    
}
