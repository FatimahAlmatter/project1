//
//  MyPostAPI.swift
//  project1
//
//  Created by فاطمه المطر on 29/07/2021.
//

import Foundation
import FirebaseDatabase

class MyPostAPI {
    
    var myPost_ref = Database.database().reference().child("MyPost")
    
    func observeNumberOfPosts(userID : String , completion : @escaping (Int)->Void) {
        myPost_ref.child(userID).observe(.value) { (snapshot) in
            let count = snapshot.childrenCount
            completion(Int(count))
        }
    }

}
