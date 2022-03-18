//
//  CommentReplyViewController.swift
//  project1
//
//  Created by فاطمه المطر on 14/07/2021.
//

import UIKit
import FirebaseDatabase

class CommentReplyViewController: UIViewController {

    @IBOutlet weak var tableviewOutlet: UITableView!
    @IBOutlet weak var bottomOutlet: NSLayoutConstraint!
    @IBOutlet weak var commentTextboxOutlet: UITextField!
    @IBOutlet weak var profileImgOutlet: UIImageView!
    @IBOutlet weak var postBtnOutlet: UIButton!
    
    
    
    var commentID : String?
    var commentContainer = [CommentReplyModel]()
    var userContainer = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //note: يعني اول ماندخل الصفحه يكون التكست فيلد تحت مكانه
        UIView.animate(withDuration: 0) {
            self.bottomOutlet.constant = 10
        }
        
        tableviewOutlet.dataSource = self
        postBtnOutlet.tintColor = .lightGray

        notificationKeyboard()
        observeCommentFromDB()
        observeUserProfileIMG()
        customProfileIMG()
        commentTextField()

    }
    
    @objc func commentTextField(){
        commentTextboxOutlet.addTarget(self, action: #selector(CommentsViewController.customPostButton), for: UIControl.Event.editingChanged)
    }
    
    @objc func customPostButton(){
        guard let commentTextField = commentTextboxOutlet.text, !commentTextField.isEmpty else {
            postBtnOutlet.tintColor = .lightGray
            return
        }
        postBtnOutlet.tintColor = .systemBlue

    }
    
    @objc func customProfileIMG(){
        profileImgOutlet.layer.borderWidth = 1
        profileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        profileImgOutlet.layer.cornerRadius = profileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        profileImgOutlet.clipsToBounds = true
        
    }
    
    @objc func observeUserFromDatabase(username: String , completion: @escaping ()-> Void) {
        
        API.user.observeUserFromDatabase(username: username) { (user) in
            self.userContainer.append(user)
            completion()
        }
    }
    
    @objc func observeUserProfileIMG(){
        guard let currentUserID = API.user.currentUser else { return }
        let currentUser = currentUserID.uid
        
        API.user.observeUserProfileIMG(currentUser: currentUser) { (user) in
            if let currentUserImgString = user.profileURL {
                let currentUserImgURL = URL(string: currentUserImgString)
                self.profileImgOutlet.sd_setImage(with: currentUserImgURL)
            }
        }
    }
    
    @objc func observeCommentFromDB(){
        
        API.LinkedCommentIDwithCommentReply.LinkedCommentIDwithCommentReply_ref.child(self.commentID!).observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            print(snapshot.key)
            
            API.commentReply.observeCommentFromDB(snapshot: snapshot.key) { (commentReply) in
                self.observeUserFromDatabase(username: commentReply.userid!) {
                    self.commentContainer.append(commentReply)
                    self.tableviewOutlet.reloadData()
                }
            }
            
        }
    }

    
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0) {
            self.bottomOutlet.constant = 10
        }
    }
    
    @objc func showKeyboard(notification : Notification) {
        //next print show keyboard size
        //print(notification)
        //next حولنا النوتفكيشن الى ارقام
        let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        // note:اذا طلع الكيبورد يصير التكست فيلد فوقه مباشره
        UIView.animate(withDuration: 0) {
            self.bottomOutlet.constant = keyboard!.height
        }
        
    }
    
    @objc func notificationKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func postCommentBtn(_ sender: Any) {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let commentRef = ref.child("CommentsReply")
        let newCommentID = commentRef.childByAutoId().key
        let newCommentREF = commentRef.child(newCommentID!)
        
        guard let currentUserID = API.user.currentUser else { return }
        let currentUser = currentUserID.uid
        
        newCommentREF.setValue(["comment": commentTextboxOutlet.text! , "userID": currentUser]) { (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }else{
                //note: اذا كل شي اوكي ، ينربط المعرف تبع البوست المنشور بالمعرف تبع الكومنت
                let linkedPostIdWithCommentID = Database.database().reference().child("linkedCommentIdWithCommentReplyID").child(self.commentID!).child(newCommentID!)
                linkedPostIdWithCommentID.setValue(true) { (error, ref) in
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromReplyCommentToUserProfileVC" {
            //l اعمل لي الانتقال
            let userProfileScreen = segue.destination as? UserProfileViewController
            userProfileScreen?.userID = sender as! String
        }
        
    }
    

}

extension CommentReplyViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentReplyCell", for: indexPath) as! CommentReplyCell
        let commentInfo = commentContainer[indexPath.row]
        cell.commentReplyContent = commentInfo
        let userInfo = userContainer[indexPath.row]
        cell.userReplyContent = userInfo
        cell.selectDelegate = self
        return cell
    }
    
    
}

extension CommentReplyViewController : CommentReplyCellDelegate {
    func goToUserProfileVC(userid: String) {
        performSegue(withIdentifier: "fromReplyCommentToUserProfileVC", sender: userid)
    }
    
    
}
