//
//  ProfileCollectionViewCell.swift
//  project1
//
//  Created by فاطمه المطر on 18/07/2021.
//

import UIKit
import SDWebImage

protocol ProfileCollectionViewCellDelegate {
    func goToPostDetails(postID : String)
}


class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImgOutlet: UIImageView!
    
    var postImgDelegate : ProfileCollectionViewCellDelegate?
    
    
    var post : PostModel? {
        didSet{
            updatePostImg()
        }
    }
    
    func updatePostImg(){
        if let postImgString = post?.PostImgREF {
            let postImgURL = URL(string: postImgString)
            postImgOutlet.sd_setImage(with: postImgURL)
            
        }
        
        let postImgGesture = UITapGestureRecognizer(target: self, action: #selector(postImgClick))
        postImgOutlet.addGestureRecognizer(postImgGesture)
        postImgOutlet.isUserInteractionEnabled = true
    }
    
    @objc func postImgClick(){
        if let postID = post?.postID {
            postImgDelegate?.goToPostDetails(postID: postID)
        }
        
    }
}
