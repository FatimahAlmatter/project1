//
//  ProfileHeaderCollectionReusableView.swift
//  project1
//
//  Created by فاطمه المطر on 18/07/2021.
//

import UIKit
import SDWebImage

protocol ProfileHeaderCollectionReusableViewDelegate {
    func transferFollowBtnStatus(userID : UserModel)
}

protocol HeaderProfileDelegate {
    func goToProfileSetting()
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImgOutlet: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var bioOutlet: UILabel!
    @IBOutlet weak var postCountOutlet: UILabel!
    @IBOutlet weak var followersOutlet: UILabel!
    @IBOutlet weak var followingOutlet: UILabel!
    @IBOutlet weak var editProfileBtnOutlet: UIButton!
    @IBOutlet weak var websiteOutlet: UILabel!
    
    var followDelegate: ProfileHeaderCollectionReusableViewDelegate?
    var selectDelegate: HeaderProfileDelegate?
    
    var user : UserModel? {
        didSet{
            updateUserInfo()
        }
    }
    
    func updateUserInfo(){
        self.userNameOutlet.text = user?.username
        self.bioOutlet.text = user?.bio
        self.websiteOutlet.text = user?.website
        // i من خلال اليوزر بندخل على صورة البروفايل
        if let profileImgString =  user?.profileURL {
            let profileImgURL = URL(string: profileImgString)
            self.profileImgOutlet.sd_setImage(with: profileImgURL)
            self.customProfileIMG()
        }
    
    
        //the following counts is for Counting (posts,following, followers)
        
        if let postCount = user {
            API.myPost.observeNumberOfPosts(userID: postCount.id!) { (number) in
                self.postCountOutlet.text = "\(number)"
            }
        }
        
        if let followersCount = user {
            API.followApi.observeNumberOfFollowers(userID: followersCount.id!) { (number) in
                self.followersOutlet.text = "\(number)"
            }
            
        }
        
        if let followingCount = user {
            API.followApi.observeNumberOfFollowing(userID: followingCount.id!) { (number) in
                self.followingOutlet.text = "\(number)"
                
            }
        }
        
        if user?.id == API.user.currentUser?.uid {
            editProfileBtnOutlet.setTitle("Edit Profile", for: UIControl.State.normal)
            editProfileBtnOutlet.addTarget(self, action: #selector(goToSetting), for: UIControl.Event.touchUpInside)
        } else {
            if user?.isFollowing == true {
                isFollowing()
            }else{
                isFollow()
            }
        }
    }
    
    @objc func goToSetting(){
        selectDelegate?.goToProfileSetting()
    }
    
    @objc func isFollow(){
        editProfileBtnOutlet.setTitle("Follow", for: UIControl.State.normal)
        editProfileBtnOutlet.addTarget(self, action: #selector(follow), for: UIControl.Event.touchUpInside)
            }
    
    @objc func isFollowing(){
        editProfileBtnOutlet.setTitle("Following", for: UIControl.State.normal)
        editProfileBtnOutlet.addTarget(self, action: #selector(unFollow), for: UIControl.Event.touchUpInside)
    }
    
    @objc func follow(){
        if user!.isFollowing == false {
            API.followApi.follow(user: user!.id!)
            user!.isFollowing = true
            isFollowing()
            followDelegate?.transferFollowBtnStatus(userID: user!)
        }
    }
    
    @objc func unFollow(){
        if user!.isFollowing == true {
            API.followApi.unfollow(user: user!.id!)
            user!.isFollowing = false
            isFollow()
            followDelegate?.transferFollowBtnStatus(userID: user!)
            
        }
    }
    
    @objc func customProfileIMG(){
        profileImgOutlet.layer.borderWidth = 1
        profileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        profileImgOutlet.layer.cornerRadius = profileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        profileImgOutlet.clipsToBounds = true
        
    }
    
    
}
