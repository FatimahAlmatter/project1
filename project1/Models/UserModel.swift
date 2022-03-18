//
//  UserModel.swift
//  project1
//
//  Created by فاطمه المطر on 07/07/2021.
//

import Foundation

class UserModel {
    var email : String?
    var profileURL : String?
    var userID : String?
    var username : String?
    var id : String?
    var isFollowing : Bool?
    var website : String?
    var phone : String?
    var bio : String?
    var name : String?

}

extension UserModel {
    static func transformUserModel(dic : [String : Any] , key : String) -> UserModel {
        let users = UserModel()
        users.id = key
        users.email = dic["email"] as? String
        users.profileURL = dic["profileURL"] as? String
        users.userID = dic["userID"] as? String
        users.username = dic["username"] as? String
        users.bio = dic["bio"] as? String
        users.name = dic["name"] as? String
        users.phone = dic["phone"] as? String
        users.website = dic["website"] as? String
        
        
        return users
    }
}
