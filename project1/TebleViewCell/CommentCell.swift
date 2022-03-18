//
//  CommentCell.swift
//  project1
//
//  Created by فاطمه المطر on 11/07/2021.
//

import UIKit
//note نحتاجها لاستخراج الصور من الداتابيس
import SDWebImage

protocol CommentCellDelegate {
    func goToUserProfileVC (userid : String)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileImgOutlet: UIImageView!
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var userCommentOutlet: UILabel!
    @IBOutlet weak var hrsOutlet: UILabel!
    @IBOutlet weak var numOfLikesOutlet: UIButton!
    @IBOutlet weak var likeImgOutlet: UIImageView!
    @IBOutlet weak var replyOutlet: UILabel!
    
    var commentVC : CommentsViewController?
    var selectDelegate : CommentCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customProfileIMG()
        
        let commentReplyGesture = UITapGestureRecognizer(target: self, action: #selector(CommentToReplySegue))
        replyOutlet.addGestureRecognizer(commentReplyGesture)
        replyOutlet.isUserInteractionEnabled = true
        
        let usernameGesture = UITapGestureRecognizer(target: self, action: #selector(commentToUserProfileVC))
        usernameOutlet.addGestureRecognizer(usernameGesture)
        usernameOutlet.isUserInteractionEnabled = true
        
        
    }
    
    @objc func commentToUserProfileVC(){
        if let userID = userContent?.id {
            selectDelegate?.goToUserProfileVC(userid: userID)
        }
    }
    
    @objc func CommentToReplySegue(){
        if let postId = commentContent?.commentID {
            commentVC?.performSegue(withIdentifier: "CommentVC_To_ReplyVC", sender: postId)
            
        }
    }
    
    @objc func customProfileIMG(){
        profileImgOutlet.layer.borderWidth = 1
        profileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        profileImgOutlet.layer.cornerRadius = profileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        profileImgOutlet.clipsToBounds = true
        
    }
    
    var commentContent : CommentModel? {
        didSet{
            updateComments()
        }
    }
    
    var userContent : UserModel? {
        didSet{
            updateUser()
        }
    }
    
    @objc func updateUser() {
        usernameOutlet.text = userContent?.username
        
        if let profileImgString = userContent?.profileURL {
            let profileImgURL = URL(string: profileImgString)
            self.profileImgOutlet.sd_setImage(with: profileImgURL)
        }
    }
    
    @objc func updateComments(){
        userCommentOutlet.text = commentContent?.comment
        updateUser()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
