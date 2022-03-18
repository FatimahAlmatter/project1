//
//  Authentication.swift
//  project1
//
//  Created by فاطمه المطر on 04/07/2021.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class Authentication {
    // First create a function for SignUp , starting with "static" word to allow us reaching this function from outside the class
    static func SignUp(username: String , email: String , password : String , profileIMG : Data , IfSignUpSuccess: @escaping ()->Void , IfSignUpError: @escaping (_ ErrorMessage : String)->Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                IfSignUpError(error!.localizedDescription)
                return
            } else {
                print("user auth successfully ! ")
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                let storage : StorageReference!
                storage = Storage.storage().reference(withPath: "gs://project1-77d4e.appspot.com/").child("profile_images").child(userID)
                
                storage.putData(profileIMG, metadata: nil) { (metaData , error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }else{
                        storage.downloadURL { (url : URL?, error : Error?) in
                            let profileURL = url?.absoluteString
                            transferDataToDatabase(username: username , email: email, profileURL: profileURL!, userID: userID)
                        }
                    }
                    func transferDataToDatabase(username : String , email : String, profileURL : String , userID : String){
                        let ref : DatabaseReference!
                        ref = Database.database().reference()
                        //create user reference
                        let userRef = ref.child("Users")
                        //note: هنا كأننا ندخل على مجلد اليوزرز و نظيف لها جذر وهو يوزر اي دي
                        let newUserRef = userRef.child(userID)
                        // username_lowerCase is just for searching purpose
                        newUserRef.setValue(["username" : username , "username_lowerCase" : username.lowercased() , "email" : email , "profileURL" : profileURL , "userID" : userID])
                        //Note: هنا لما يسجل بشكل صحيح نحفظ البيانات فالداتابيس
                        IfSignUpSuccess()
                    }
                }
            }
        }
    }
    
    static func SignIn(email : String, password: String, IfSignInSuccess: @escaping ()-> Void, IfSignInError: @escaping (_ ErrorMessage: String)-> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (user , error ) in
            if error != nil {
                IfSignInError(error!.localizedDescription)
                return
            }else{
                IfSignInSuccess()
                
            }
        }
    }
    
    static func SharePost(videoURL : URL? = nil , imageData: Data , caption: String , imageSize : CGFloat , IfCameraVCSuccess: @escaping ()->Void , IfCameraVCError: @escaping (_ ErrorMessage : String)->Void ){
        
        if let sharedVideo = videoURL {
            uploadVideoToStorage(videoURL: sharedVideo) { (video) in
                uploadImgToStorage(imageData: imageData) { (thumbnailImg) in
                    self.transferDataToDatabase(videoURL: video, imageSize: imageSize, Caption: caption, postImgREF: thumbnailImg, IfSuccess: IfCameraVCSuccess, IfError: IfCameraVCError)
                }
            }
        }
        
        uploadImgToStorage(imageData: imageData) { (imageURL) in
            self.transferDataToDatabase(imageSize: imageSize, Caption: caption, postImgREF: imageURL, IfSuccess: IfCameraVCSuccess, IfError: IfCameraVCError)
        }
    }
    
    
    static func uploadVideoToStorage(videoURL : URL , IfSuccess : @escaping (_ imageURL : String)->Void){
        let videoID = NSUUID().uuidString
        let storageREF = Storage.storage().reference(withPath: "gs://project1-77d4e.appspot.com").child("Video-Folder").child(videoID)
        let metaData = StorageMetadata()
        metaData.contentType = "video/quicktime"
        if let videoData = NSData(contentsOf: videoURL) as Data? {
            storageREF.putData(videoData, metadata: metaData) { (SMeta, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                storageREF.downloadURL { (url : URL?, error : Error?) in
                    if let postImgREF = url?.absoluteString {
                        IfSuccess(postImgREF)
                    }
                }
            }
        }
        
    }
    
    
    static func uploadImgToStorage(imageData : Data , IfSuccess : @escaping (_ ImageURL : String)->Void){
        let postImgID = NSUUID().uuidString
        let storageREF = Storage.storage().reference(withPath: "gs://project1-77d4e.appspot.com").child("Image-Folder").child(postImgID)
        storageREF.putData(imageData, metadata: nil) { (metaData , error) in
            if error != nil {
                return
            }else{
                storageREF.downloadURL { (url : URL?, error: Error?) in
                    if let postImgREF = url?.absoluteString {
                        IfSuccess(postImgREF)
                    }
                }
            }
        }
    }
    
    static func transferDataToDatabase(videoURL : String? = nil , imageSize : CGFloat, Caption: String , postImgREF : String , IfSuccess : @escaping ()->Void , IfError : @escaping (_ errorString : String)->Void ) {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let postREF = ref.child("Posts")
        
        //note: نستخرج من هو اليوزر الحالي
        guard let currentUserPostID = Auth.auth().currentUser else { return  }
        //note: نطلع الآي دي لليوزر الحالي
        let userID = currentUserPostID.uid
        //note: هنا يعني كل بوست له آي دي محدد
        let newPostID = postREF.childByAutoId().key
        let newPostREF = postREF.child(newPostID!)
        
        var values = ["userID": userID ,"Caption" : Caption , "PostImgREF" : postImgREF , "imageSize" : imageSize] as [String : Any]
        
        if let video = videoURL {
            values["VideoURL"] = video
        }
        newPostREF.setValue(values) { (error,ref) in
            if error != nil {
                IfError(error!.localizedDescription)
                return
            }else{
                API.feedApi.feed_ref.child(API.user.currentUser!.uid).child(newPostID!).setValue(true)
                //i ننشئ جذر لحفظ البوستات لكل يوزر لحاله عشان نستدعيهم في البروفايل سكرين
                let myPost_REF = API.myPost.myPost_ref.child(userID).child(newPostID!)
                //i هنا لازم نستخدم الست فاليو اللي معاها كومبليشن بلوك لآن ممكن نرسل المنشور لقاعدة البيانات و ممكن يكون في خطأ
                myPost_REF.setValue(true) { (error, ref) in
                    if error != nil {
                        IfError(error!.localizedDescription)
                        return
                    }
                }
                //note: move to home page after posting an image
                IfSuccess()
            }
        }
    }
    
    static func logOut(IfLogOutSuccess: @escaping ()->Void , IfLogOutError: @escaping (_ ErrorMessage : String)->Void) {
        do {
            try Auth.auth().signOut()
            IfLogOutSuccess()
        } catch let error {
            IfLogOutError(error.localizedDescription)
        }
        
    }
    
    static func updateUserInfo(username: String , email: String , password : String ,name: String , phone: String , website: String , bio: String, profileIMG : Data , IfUpdateSuccess: @escaping ()->Void , IfUpdateError: @escaping (_ ErrorMessage : String)->Void){
        
        API.user.currentUser?.updatePassword(to: password, completion: { (error) in
            if error != nil {
                IfUpdateError(error!.localizedDescription)
            }
        })
        
        API.user.currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                IfUpdateError(error!.localizedDescription)
            }
        })
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storage : StorageReference!
        storage = Storage.storage().reference(withPath: "gs://project1-77d4e.appspot.com/").child("profile_images").child(userID)
        
        storage.putData(profileIMG, metadata: nil) { (metaData , error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }else{
                storage.downloadURL { (url : URL?, error : Error?) in
                    let profileURL = url?.absoluteString
                    transferDataToDatabase(username: username, email: email, profileURL: profileURL!, userID: userID, website: website, name: name, bio: bio, phone: phone)
                }
            }
            func transferDataToDatabase(username : String , email : String, profileURL : String , userID : String , website : String , name : String , bio : String , phone : String){
                let ref : DatabaseReference!
                ref = Database.database().reference()
                //create user reference
                let userRef = ref.child("Users")
                //note: هنا كأننا ندخل على مجلد اليوزرز و نظيف لها جذر وهو يوزر اي دي
                let newUserRef = userRef.child(userID)
                // username_lowerCase is just for searching purpose
                newUserRef.setValue(["username" : username , "username_lowerCase" : username.lowercased() , "email" : email , "website" : website , "name" : name , "bio" : bio , "phone" : phone ,  "profileURL" : profileURL , "userID" : userID])
                //Note: هنا لما يسجل بشكل صحيح نحفظ البيانات فالداتابيس
                IfUpdateSuccess()
            }
        }
    }
}


