//
//  CommentReplyCell.swift
//  project1
//
//  Created by فاطمه المطر on 14/07/2021.
//

import UIKit

protocol CommentReplyCellDelegate {
    func goToUserProfileVC (userid : String)
}

class CommentReplyCell: UITableViewCell {

    @IBOutlet weak var profileImgOutlet: UIImageView!
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var userCommentOutlet: UILabel!
    @IBOutlet weak var hrsOutlet: UILabel!
    @IBOutlet weak var numOfLikesOutlet: UIButton!
    @IBOutlet weak var likeImgOutlet: UIImageView!
    
    var selectDelegate : CommentReplyCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        customProfileIMG()

    }
    
    @objc func customProfileIMG(){
        profileImgOutlet.layer.borderWidth = 1
        profileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        profileImgOutlet.layer.cornerRadius = profileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        profileImgOutlet.clipsToBounds = true
        
    }
    
    var commentReplyContent : CommentReplyModel? {
        didSet{
            updateComments()
        }
    }
    
    var userReplyContent : UserModel? {
        didSet{
            updateUser()
        }
    }
    
    @objc func updateUser() {
        usernameOutlet.text = userReplyContent?.username
        
        if let profileImgString = userReplyContent?.profileURL {
            let profileImgURL = URL(string: profileImgString)
            self.profileImgOutlet.sd_setImage(with: profileImgURL)
        }
        
        let usernameGesture = UITapGestureRecognizer(target: self, action: #selector(commentToUserProfileVC))
        usernameOutlet.addGestureRecognizer(usernameGesture)
        usernameOutlet.isUserInteractionEnabled = true
        
    }
    @objc func commentToUserProfileVC(){
        if let userID = userReplyContent?.id {
            selectDelegate?.goToUserProfileVC(userid: userID)
        }
    }
    
    @objc func updateComments(){
        userCommentOutlet.text = commentReplyContent?.comment
        updateUser()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
