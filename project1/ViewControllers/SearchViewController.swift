//
//  SearchViewController.swift
//  project1
//
//  Created by فاطمه المطر on 04/08/2021.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    let searchBar = UISearchBar()
    var userContainer : [UserModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        tableViewOutlet.dataSource = self
        // setup Search Box
        searchBar.searchBarStyle = .default
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 50
        let searchItem = UIBarButtonItem(customView: searchBar)
        navigationItem.rightBarButtonItem = searchItem
        
        observeSearch()
        
    }
    
    @objc func observeSearch() {
        self.userContainer.removeAll()
        self.tableViewOutlet.reloadData()
        if let searchText = searchBar.text?.lowercased() {
            API.user.observeSearch(withText: searchText) { (user) in
                
                if user.id != API.user.currentUser?.uid {
                    self.isFollowing(user: user.id!) { (value) in
                        user.isFollowing = value
                        self.userContainer.append(user)
                        self.tableViewOutlet.reloadData()
                    }
                    
                }
            }
        }
    }
    
    @objc func isFollowing(user : String , completed : @escaping (Bool)->Void){
        API.followApi.isFollowing(user: user, completion: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchVC_To_UserProfileVC" {
            //l اعمل لي الانتقال
            let userProfileScreen = segue.destination as? UserProfileViewController
            userProfileScreen?.userID = sender as! String
            userProfileScreen?.headerDelegate = self
            
        }
    }
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        observeSearch()
    }
    
}

extension SearchViewController : UITableViewDataSource {
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


extension SearchViewController : DiscoverNewUsersCellDelegate {
    func GoToUserProfile(userid: String) {
        performSegue(withIdentifier: "SearchVC_To_UserProfileVC", sender: userid)
    }
}

extension SearchViewController : ProfileHeaderCollectionReusableViewDelegate {
    func transferFollowBtnStatus(userID: UserModel) {
        for users in userContainer {
            if users.id == userID.id {
                users.isFollowing = userID.isFollowing
                self.tableViewOutlet.reloadData()
            }
        }
    }
    
    
}
