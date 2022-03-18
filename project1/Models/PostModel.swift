//
//  PostModel.swift
//  project1
//
//  Created by فاطمه المطر on 07/07/2021.
//

import Foundation
import FirebaseAuth

class PostModel {
    var Caption : String?
    var PostImgREF : String?
    var userID : String?
    var postID : String?
    var likes : Dictionary<String, Any>?
    var likesCount : Int?
    var isLiked : Bool?
    var imageSize : CGFloat?
    var VideoURL : String?
    
}

extension PostModel {
    static func transformPostModel(dic : [String : Any], key : String) -> PostModel {
        let newPost = PostModel()
        newPost.postID = key
        newPost.Caption = dic["Caption"] as? String
        newPost.PostImgREF = dic["PostImgREF"] as? String
        newPost.userID = dic["userID"] as? String
        newPost.likes = dic["likes"] as? Dictionary<String , Any>
        newPost.likesCount = dic["likesCount"] as? Int
        newPost.imageSize = dic["imageSize"] as? CGFloat
        newPost.VideoURL = dic["VideoURL"] as? String
        
        if let currentUser = Auth.auth().currentUser?.uid {
            // i عملنا وظيفه تشيك اذا المستخدم الحالي عمل لايك أو لأ
            if newPost.likes != nil {
                newPost.isLiked = newPost.likes![currentUser] != nil
            }
        }
        
        return newPost
        
    }
}
