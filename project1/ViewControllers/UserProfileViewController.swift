//
//  UserProfileViewController.swift
//  project1
//
//  Created by فاطمه المطر on 03/08/2021.
//

import UIKit

class UserProfileViewController: UIViewController {

    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    var userID = ""
    var userContainer : UserModel!
    var postContainer : [PostModel] = []
    var headerDelegate : ProfileHeaderCollectionReusableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewOutlet.dataSource = self
        collectionViewOutlet.delegate = self
        observeUserInfo()
        observeMypost()

    }
    
    @objc func observeUserInfo() {
        API.user.observeUserFromDatabase(username: userID) { (user) in
            self.isFollowing(user: user.id!) { (value) in
                user.isFollowing = value
                self.userContainer = user
                //i يحط لي اسم المستخدم كتايتل في النص في صفحة البروفايل
                self.title = user.username
                self.collectionViewOutlet.reloadData()
            }
        }
    }
    
    @objc func isFollowing(user : String , completed : @escaping (Bool)->Void){
        API.followApi.isFollowing(user: user, completion: completed)
    }
    
    @objc func observeMypost(){
        
        API.myPost.myPost_ref.child(userID).observe(.childAdded) { (snapshot) in
            API.post.observePostWithID(withID: snapshot.key) { (post) in
                self.postContainer.append(post)
                self.collectionViewOutlet.reloadData()
            }
        }
    }
    
}

extension UserProfileViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! ProfileCollectionViewCell
        let postInfo = postContainer[indexPath.row]
        cell.post = postInfo
        return cell
    }
    
    
    //Following func is for the header in collectionView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderIdentifier", for: indexPath) as! ProfileHeaderCollectionReusableView
        
        headerViewCell.user = userContainer
        headerViewCell.followDelegate = headerDelegate
        headerViewCell.selectDelegate = self
        return headerViewCell
    }
    
    
}

extension UserProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        //i معناها في كل صف ثلاث صور
        let cellSize : CGFloat = screenWidth / 3 - 2
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserProfileViewController : HeaderProfileDelegate {
    func goToProfileSetting() {
        performSegue(withIdentifier: "fromUserProfile_ToSetting", sender: nil)
    }
    
    
}

