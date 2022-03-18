//
//  DiscoverViewController.swift
//  project1
//
//  Created by فاطمه المطر on 14/06/2021.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    var postContainer : [PostModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewOutlet.dataSource = self
        collectionViewOutlet.delegate = self
        
        
    }
    
    // to be updated all time
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        observeMypost()

    }
    
    @objc func observeMypost(){
        //the following 2Lines are to avoid post repeating in the view
        self.postContainer.removeAll()
        self.collectionViewOutlet.reloadData()
        
        API.post.observeTopLikedPosts { (post) in
            self.postContainer.append(post)
            self.collectionViewOutlet.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPostDetails" {
            //l اعمل لي الانتقال
            let postImgDetailsScreen = segue.destination as? PostDetailsViewController
            postImgDetailsScreen?.postID = sender as! String
        }
    }
    
    
}

extension DiscoverViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionCell", for: indexPath) as! ProfileCollectionViewCell
        let postInfo = postContainer[indexPath.row]
        cell.post = postInfo
        cell.postImgDelegate = self
        return cell
    }
     
}

extension DiscoverViewController : UICollectionViewDelegateFlowLayout {
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

extension DiscoverViewController : ProfileCollectionViewCellDelegate {
    func goToPostDetails(postID: String) {
        performSegue(withIdentifier: "ToPostDetails", sender: postID)
    }
    
    
}

