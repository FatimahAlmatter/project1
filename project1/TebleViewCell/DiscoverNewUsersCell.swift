//
//  DiscoverNewUsersCell.swift
//  project1
//
//  Created by فاطمه المطر on 30/07/2021.
//

import UIKit
import SDWebImage


//i البروتوكول يفضل يكون اسمه نفس الكلاس ونضيف عليه دلقيت
protocol DiscoverNewUsersCellDelegate {
    func GoToUserProfile(userid : String)
}

class DiscoverNewUsersCell: UITableViewCell {

    @IBOutlet weak var userImgOutlet: UIImageView!
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var FollowBtnOutlet: UIButton!
    var discoverUsers : DiscoveNewUsersViewController?
    
    //i بعد ما نسوي البروتوكول نضيف هالمتغير
    var selectDelegate : DiscoverNewUsersCellDelegate?
    
    var user : UserModel! {
        didSet{
            userInfo()
        }
        
    }
    
    func userInfo () {
        usernameOutlet.text = user.username
        if let imgString = user?.profileURL {
            let imgURL = URL(string: imgString)
            self.userImgOutlet.sd_setImage(with: imgURL)
            self.customUserImg()
        }
        if user?.isFollowing == true {
            isFollowing()
        }else{
            isFollow()
        }
    }
    
    @objc func isFollow(){
        FollowBtnOutlet.setTitle("Follow", for: UIControl.State.normal)
        FollowBtnOutlet.addTarget(self, action: #selector(follow), for: UIControl.Event.touchUpInside)
            }
    
    @objc func isFollowing(){
        FollowBtnOutlet.setTitle("Following", for: UIControl.State.normal)
        FollowBtnOutlet.addTarget(self, action: #selector(unFollow), for: UIControl.Event.touchUpInside)
    }
    
    @objc func follow(){
        if user.isFollowing == false {
            API.followApi.follow(user: user!.id!)
            user.isFollowing = true
            isFollowing()
        }
    }
    
    @objc func unFollow(){
        if user.isFollowing == true {
            API.followApi.unfollow(user: user!.id!)
            user.isFollowing = false
            isFollow()
        }
    }
    
    @objc func customUserImg(){
        userImgOutlet.layer.borderWidth = 1
        userImgOutlet.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        userImgOutlet.layer.cornerRadius = userImgOutlet.frame.height / 2
        userImgOutlet.clipsToBounds = true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //when we click on usename
        let userProfileGesture = UITapGestureRecognizer(target: self, action: #selector(discoverToUserProfileSegue))
        usernameOutlet.addGestureRecognizer(userProfileGesture)
        usernameOutlet.isUserInteractionEnabled = true

    }
    
    @objc func discoverToUserProfileSegue(){
        if let id = user?.id {
            selectDelegate!.GoToUserProfile(userid: id)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
