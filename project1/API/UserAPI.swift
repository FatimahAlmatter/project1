//
//  UserAPI.swift
//  project1
//
//  Created by فاطمه المطر on 17/07/2021.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserAPI {
    var user_ref = Database.database().reference().child("Users")
    var currentUser : User? {
        if let currentUserUID = Auth.auth().currentUser {
            return currentUserUID
        }
        return nil
    }
    
    func observeCurrentUserInfo(completed : @escaping (UserModel) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
            
        }
        user_ref.child(currentUser.uid).observeSingleEvent(of: DataEventType.value) { (snapshot : DataSnapshot) in
            
            if let dic = snapshot.value as? [String : Any]{
                let user = UserModel.transformUserModel(dic: dic, key: snapshot.key)
                completed(user)
                
            }
        }
    }
    
    
    
    func observeUserFromDatabase(username : String , completed : @escaping (UserModel) -> Void){
        user_ref.child(username).observe(DataEventType.value) { (snapshot: DataSnapshot) in
            if let dic = snapshot.value as? [String : Any]{
                let user = UserModel.transformUserModel(dic: dic, key: snapshot.key)
                completed(user)
            }
        }
        
    }
    
    func observeUserProfileIMG(currentUser: String, completed : @escaping (UserModel) -> Void){
        user_ref.child(currentUser).observeSingleEvent(of: DataEventType.value) { (snapshot : DataSnapshot) in
            if let dic = snapshot.value as? [String : Any]{
                let user = UserModel.transformUserModel(dic: dic, key: snapshot.key)
                completed(user)
            }
        }
    }
    
    func observeAllUsers(completion : @escaping (UserModel) -> Void) {
        user_ref.observe(.childAdded) { (snapshot : DataSnapshot) in
            if let dic = snapshot.value as? [String : Any] {
                //print(snapshot.value)
                let user = UserModel.transformUserModel(dic: dic, key: snapshot.key)
                completion(user)
            }
            
        }
    }
    
    func observeSearch(withText text : String, completed : @escaping (UserModel)->Void ) {
        user_ref.queryOrdered(byChild: "username_lowerCase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 3).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach { (child) in
                let children = child as! DataSnapshot
                if let dic = children.value as? [String : Any] {
                    let user = UserModel.transformUserModel(dic: dic, key: children.key)
                    completed(user)
                }
            }
        }
    }
    
}

