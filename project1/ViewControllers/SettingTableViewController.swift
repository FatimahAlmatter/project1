//
//  SettingTableViewController.swift
//  project1
//
//  Created by فاطمه المطر on 09/08/2021.
//

import UIKit
import JGProgressHUD

class SettingTableViewController: UITableViewController , UITextFieldDelegate {

    @IBOutlet weak var prfileImgOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var websiteOutlet: UITextField!
    @IBOutlet weak var bioOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var phoneOutlet: UITextField!
    @IBOutlet weak var editImgOutlet: UIButton!
    @IBOutlet weak var passwordOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordOutlet.delegate = self
        nameOutlet.delegate = self
        usernameOutlet.delegate = self
        bioOutlet.delegate = self
        websiteOutlet.delegate = self
        emailOutlet.delegate = self
        phoneOutlet.delegate = self
        
        fitchCurrentUserInfo()
        customProfileIMG()
        changeProfileImg()
        
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        if let profileImage = self.prfileImgOutlet.image , let profileIMG = profileImage.jpegData(compressionQuality: 0.1) {
            Authentication.updateUserInfo(username: usernameOutlet.text!, email: emailOutlet.text!, password: passwordOutlet.text!, name: nameOutlet.text!, phone: phoneOutlet.text!, website: websiteOutlet.text!, bio: bioOutlet.text!, profileIMG: profileIMG) {
                //if success:
                let hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "تم تحديث بيانلتك بنجاح"
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0)
            } IfUpdateError: { (error) in
                let hud = JGProgressHUD()
                hud.textLabel.text = "لم يتم تحديث البيانات ، حاول مرة اخرى"
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0)
            }

        }
        
    }
    @objc func changeProfileImg(){
        
        let profileImgGesture = UITapGestureRecognizer(target: self, action:#selector(pickProfileImg))
        editImgOutlet.addGestureRecognizer(profileImgGesture)
        editImgOutlet.isUserInteractionEnabled = true
        
    }
    
    @objc func pickProfileImg(){
        let profileImgPicker = UIImagePickerController()
        profileImgPicker.allowsEditing = true
        profileImgPicker.delegate = self
        present(profileImgPicker, animated: true, completion: nil)
    }
    
    @objc func fitchCurrentUserInfo(){
        API.user.observeCurrentUserInfo { (user) in
            self.usernameOutlet.text = user.username
            self.emailOutlet.text = user.email
            self.nameOutlet.text = user.name
            self.websiteOutlet.text = user.website
            self.bioOutlet.text = user.bio
            self.phoneOutlet.text = user.phone

            
            
            if let imageString = user.profileURL {
                let image = URL(string: imageString)
                self.prfileImgOutlet.sd_setImage(with: image)
            }
        }
    }
    
    @objc func customProfileIMG(){
        prfileImgOutlet.layer.borderWidth = 1
        prfileImgOutlet.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        prfileImgOutlet.layer.cornerRadius = prfileImgOutlet.frame.height / 2
        //note: هنا لو الصوره اكبر من الحواف راح يقصها لنا
        prfileImgOutlet.clipsToBounds = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SettingTableViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userSelectedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            prfileImgOutlet.image = userSelectedImg
        }
        dismiss(animated: true, completion: nil)
    }
}


