//
//  DiscoveNewUsersViewController.swift
//  project1
//
//  Created by فاطمه المطر on 30/07/2021.
//

import UIKit

class DiscoveNewUsersViewController: UIViewController {

    
    @IBOutlet weak var tableViewOutlet: UITableView!
    var userContainer : [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewOutlet.dataSource = self

        ObserveAllUsers()
        
    }
    
    @objc func ObserveAllUsers(){
        API.user.observeAllUsers { (user) in
            guard let currentUser = API.user.currentUser?.uid else { return }
            if user.id != currentUser {
                self.isFollowing(user: user.id!) { (value) in
                    user.isFollowing = value
                    self.userContainer.append(user)
                    self.tableViewOutlet.reloadData()
                }
                
            }
        }
    }
    
    @objc func isFollowing(user : String , completed : @escaping (Bool)->Void){
        API.followApi.isFollowing(user: user, completion: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromDiscover_To_UserProfile" {
            //l اعمل لي الانتقال
            let userProfileScreen = segue.destination as? UserProfileViewController
            userProfileScreen?.userID = sender as! String
            userProfileScreen?.headerDelegate = self
        }
    }
    


}
extension DiscoveNewUsersViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiscoverNewUsersCell
        let userInfo = userContainer[indexPath.row]
        cell.user = userInfo
        cell.selectDelegate = self
        return cell
    }
}

extension DiscoveNewUsersViewController : DiscoverNewUsersCellDelegate {
    func GoToUserProfile(userid: String) {
        performSegue(withIdentifier: "FromDiscover_To_UserProfile", sender: userid)
    }
}

extension DiscoveNewUsersViewController : ProfileHeaderCollectionReusableViewDelegate {
    func transferFollowBtnStatus(userID: UserModel) {
        for users in userContainer {
            if users.id == userID.id {
                users.isFollowing = userID.isFollowing
                self.tableViewOutlet.reloadData()
            }
        }
    }
    
    
}
