//
//  HomeViewController.swift
//  project1
//
//  Created by فاطمه المطر on 14/06/2021.
//

import UIKit
import JGProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var postContainer = [PostModel]()
    var userContainer = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        observePostsFromDatabase()
    }
    
    // to get post data from database
    func observePostsFromDatabase() {
        //i يجيب لي بوستات المستخدمين اللي اتابعهم فقط
        API.feedApi.observeFeedPost(user: API.user.currentUser!.uid) { (post) in
            self.observeUserFromDatabase(username: post.userID!) {
                self.postContainer.append(post)
                self.tableViewOutlet.reloadData()
                
            }
            API.feedApi.observeRemovedPostsFromFeed(userid: API.user.currentUser!.uid) { (post) in
                // $0.postID > معناها يدخل على كل المفاتيح الخاصه بالبوست اي دي
                self.postContainer = self.postContainer.filter {$0.postID != post.postID }
                self.userContainer = self.userContainer.filter {$0.id != post.userID }
                self.tableViewOutlet.reloadData()

            }
        }
    }
    
    @objc func observeUserFromDatabase(username: String , completion: @escaping ()-> Void) {
        API.user.observeUserFromDatabase(username: username) { (user) in
            self.userContainer.append(user)
            completion()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeVC_To_CommentsVC" {
            //l اعمل لي الانتقال
            let commentScreen = segue.destination as? CommentsViewController
            commentScreen?.postID = sender as? String
        }
        
        if segue.identifier == "ToUserProfileVC" {
            //l اعمل لي الانتقال
            let profileScreen = segue.destination as? UserProfileViewController
            profileScreen?.userID = sender as! String
        }
    }
    
    @IBAction func signOutBtn(_ sender: Any) {
        Authentication.logOut {
            //d عشان ننتقل الى صفحة تسجيل الدخول
            // d الفاريبل التالي سميناه على اسم الستوري بورد مين - وبكذا نكون عرفنا الصفحه و دخلنا عليها
            let main = UIStoryboard(name: "Main", bundle: nil)
            // d  بعدين ندخل على صفحة تسجيل الدخول
            let signInVC = main.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
            
        } IfLogOutError: { (error) in
            let hud = JGProgressHUD()
            hud.textLabel.text = "خطأ في بياناتك ! "
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
}

extension HomeViewController : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //note: indexPath indecates the location of cell in table
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeCell
        
        let postInfo = postContainer[indexPath.row]
        cell.postContent = postInfo
        
        let userInfo = userContainer[indexPath.row]
        cell.userContent = userInfo
        cell.homeVC = self
        cell.selectDelegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 592
    }
    
}

extension HomeViewController : HomeCellDelegate {
    func GoToUserProfileVC(userID: String) {
        performSegue(withIdentifier: "ToUserProfileVC", sender : userID)
        
    }
    
    func GoToCommentVC(postID: String) {
        performSegue(withIdentifier: "HomeVC_To_CommentsVC", sender: postID)
        
    }
    
}

