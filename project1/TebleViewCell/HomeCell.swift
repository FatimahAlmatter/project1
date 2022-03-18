//
//  HomeCell.swift
//  project1
//
//  Created by فاطمه المطر on 07/07/2021.
//

import UIKit
import SDWebImage
import AVFoundation

protocol HomeCellDelegate {
    func GoToCommentVC(postID : String)
    func GoToUserProfileVC(userID : String)
}

class HomeCell: UITableViewCell {

    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var profileImgOutlet: UIImageView!
    @IBOutlet weak var postImgOutlet: UIImageView!
    @IBOutlet weak var likeOutLet: UIImageView!
    @IBOutlet weak var commentOutlet: UIImageView!
    @IBOutlet weak var shareOutlet: UIImageView!
    @IBOutlet weak var numberOfLikesOutlet: UIButton!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var postImgHight: NSLayoutConstraint!
    @IBOutlet weak var soundViewOutlet: UIView!
    @IBOutlet weak var soundBtnOutlet: UIButton!
    
    
    var homeVC : HomeViewController?
    var selectDelegate : HomeCellDelegate?
    var videoPlayer : AVPlayer?
    var videoPlayerLayer : AVPlayerLayer?
    
    var postContent : PostModel? {
        didSet{
            updatePosts()
            
        }
    }
    
    var userContent : UserModel? {
        didSet{
            updateUsers()
        }
    }
    
    @objc func updateUsers(){
        userNameOutlet.text = userContent?.username
        if let profileImgString = userContent?.profileURL {
            let profileImgURL = URL(string: profileImgString)
            profileImgOutlet.sd_setImage(with: profileImgURL)
            
        }
    }
    
    @objc func updatePosts(){
        captionOutlet.text = postContent?.Caption
        if let imageSize = postContent?.imageSize {
            
            postImgHight.constant = UIScreen.main.bounds.width / imageSize
            layoutIfNeeded()
        }
        
        
        if let postImgString = postContent?.PostImgREF {
            let postImgURL = URL(string: postImgString)
            postImgOutlet.sd_setImage(with: postImgURL)
            
        }
        if let videoString = postContent?.VideoURL {
            if let videoURL = URL(string: videoString) {
                self.soundViewOutlet.isHidden = false
                videoPlayer = AVPlayer(url: videoURL)
                videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
                videoPlayerLayer?.frame = postImgOutlet.frame
                soundViewOutlet.layer.zPosition = 1
                self.contentView.layer.addSublayer(videoPlayerLayer!)
                videoPlayer?.play()
                videoPlayer?.isMuted = isMute
                customSoundBtn()

            }
            
        }
        customLikeImg(post: postContent!)
        updateUsers()
    }
    
    var isMute = true
    
    @IBAction func soundBtnClick(_ sender: Any) {
        if isMute {
            isMute = !isMute
            soundBtnOutlet.setImage(UIImage(systemName: "volume.3.fill"), for: UIControl.State.normal)
            
        }else{
            isMute = !isMute
            soundBtnOutlet.setImage(UIImage(systemName: "volume.slash.fill"), for: UIControl.State.normal)
        }
        
        videoPlayer?.isMuted = isMute
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //videoPlayerLayer?.removeFromSuperlayer()
        // to stop video when moving to another cell
        videoPlayer?.pause()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customProfileIMG()
        
        let commentGesture = UITapGestureRecognizer(target: self, action: #selector(homeToCommentsSegue))
        commentOutlet.addGestureRecognizer(commentGesture)
        commentOutlet.isUserInteractionEnabled = true
        
        let likeGesture = UITapGestureRecognizer(target: self, action: #selector(handleLikes))
        likeOutLet.addGestureRecognizer(likeGesture)
        likeOutLet.isUserInteractionEnabled = true
        
        let usernameGesture = UITapGestureRecognizer(target: self, action: #selector(usernameClick))
        userNameOutlet.addGestureRecognizer(usernameGesture)
        userNameOutlet.isUserInteractionEnabled = true
    }
    
    @objc func usernameClick(){
        if let userID = userContent?.userID{
            selectDelegate?.GoToUserProfileVC(userID: userID)
        }
    }
    
    @objc func handleLikes(){
        API.post.observeLikes(postID: postContent!.postID!) { (post) in
            self.customLikeImg(post: post)
        } IfLikeError: { (error) in
            return
        }

        
    }
    
    func customLikeImg(post : PostModel) {
        let image = post.likes == nil || !post.isLiked! ? "heart" : "heart.fill"
        likeOutLet.image = UIImage(systemName: image)
        if image == "heart.fill" {
            likeOutLet.tintColor = .systemRed
        } else {
            likeOutLet.tintColor = .systemGray
            
        }
        guard let count = post.likesCount else { return }
        if count == 0 || count != 0 {
            numberOfLikesOutlet.setTitle(" \(count) Like", for: UIControl.State.normal)
        }
    }
    
    
    @objc func homeToCommentsSegue(){
        if let postId = postContent?.postID {
            selectDelegate?.GoToCommentVC(postID: postId)            
        }
    }
    
    @objc func customProfileIMG(){
        profileImgOutlet.layer.borderWidth = 1
        profileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        profileImgOutlet.layer.cornerRadius = profileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        profileImgOutlet.clipsToBounds = true
        
    }
    
    @objc func customSoundBtn(){
        soundViewOutlet.layer.cornerRadius = soundViewOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        soundViewOutlet.clipsToBounds = true
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
