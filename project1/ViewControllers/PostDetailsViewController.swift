//
//  PostDetailsViewController.swift
//  project1
//
//  Created by فاطمه المطر on 07/08/2021.
//

import UIKit

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var postContainer = PostModel()
    var userContainer = UserModel()
    var postID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        observePostsFromDatabase()
        //print(postID)

    }
    
    func observePostsFromDatabase() {
        API.post.observePostWithID(withID: postID) { (post) in
            self.observeUserFromDatabase(username: post.userID!) {
                self.postContainer = post
                self.tableViewOutlet.reloadData()
            }
        }
    }
    
    @objc func observeUserFromDatabase(username: String , completion: @escaping ()-> Void) {
        API.user.observeUserFromDatabase(username: username) { (user) in
            self.userContainer = user
            completion()
        }
    }
    

}

extension PostDetailsViewController : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //note: indexPath indecates the location of cell in table
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostImgCell", for: indexPath) as! HomeCell
        
        cell.postContent = postContainer
        
        cell.userContent = userContainer
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 592
    }
    
}
