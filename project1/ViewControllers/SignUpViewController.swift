//
//  SignUpViewController.swift
//  project1
//
//  Created by فاطمه المطر on 12/06/2021.
//

import UIKit
import JGProgressHUD

class SignUpViewController: UIViewController , UITextFieldDelegate {

    
    @IBOutlet weak var userNameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var signUpBtnOutlet: UIButton!
    @IBOutlet weak var profileImgOutlet: UIImageView!
    
    var userSelectImageToStorage : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameOutlet.delegate = self
        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        signUpBtnOutlet.isEnabled = false
        signUpBtnOutlet.backgroundColor = UIColor.lightGray
        textFields()
        
        //to interact with profile img اول شي اخليه قابل للتفاعل بعدين اضيف التفاعل لأوتلت الصوره
        let profileImgGesture = UITapGestureRecognizer(target: self, action:#selector(pickProfileImg))
        profileImgOutlet.addGestureRecognizer(profileImgGesture)
        profileImgOutlet.isUserInteractionEnabled = true
        
    }
    
    
    @objc func pickProfileImg(){
        print("user select img")
        //the following controller will allow us to go to studio and choose img
        let profileImgPicker = UIImagePickerController()
        //to allow us to edit the img
        profileImgPicker.allowsEditing = true
        profileImgPicker.delegate = self
        //to present the view of studio
        present(profileImgPicker, animated: true, completion: nil)
    }
    
    
    @objc func textFields(){
        userNameOutlet.addTarget(self, action: #selector(SignUpViewController.textFieldsIsEmpty), for: UIControl.Event.editingChanged)
        emailOutlet.addTarget(self, action: #selector(SignUpViewController.textFieldsIsEmpty), for: UIControl.Event.editingChanged)
        passwordOutlet.addTarget(self, action: #selector(SignUpViewController.textFieldsIsEmpty), for: UIControl.Event.editingChanged)
    }
    
    
    @objc func textFieldsIsEmpty(){
        guard let userName = userNameOutlet.text , !userName.isEmpty , let password = passwordOutlet.text , !password.isEmpty, let email = emailOutlet.text, !email.isEmpty else {
            signUpBtnOutlet.backgroundColor = UIColor.lightGray
            signUpBtnOutlet.isEnabled = false
            return
        }
        signUpBtnOutlet.backgroundColor = UIColor.systemYellow
        signUpBtnOutlet.isEnabled = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func signUpBtn(_ sender: Any) {
        if let profileImage = self.userSelectImageToStorage , let profileIMG = profileImage.jpegData(compressionQuality: 0.1) {
        
            Authentication.SignUp(username: userNameOutlet.text!, email: emailOutlet.text!, password: passwordOutlet.text!, profileIMG: profileIMG, IfSignUpSuccess: {
                let hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "أهلًا بك"
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0)
                self.viewDidAppear(true)
                //note: اذا سجل اليوزر بشكل صحيح ، بينقلني الى داخل التطبيق
                self.performSegue(withIdentifier: "signUp_Identifier", sender: nil)
            }) { (error) in
                let hud = JGProgressHUD()
                hud.textLabel.text = "خطأ في بياناتك ! "
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userNameOutlet.text = ""
        emailOutlet.text = ""
        passwordOutlet.text = ""
        userSelectImageToStorage = nil
        profileImgOutlet.image = UIImage(systemName: "person.crop.circle.badge.plus")
    }
    
//    func cleanTextFields(){
//        userNameOutlet.text = ""
//        emailOutlet.text = ""
//        passwordOutlet.text = ""
//        userSelectImageToStorage = nil
//        profileImgOutlet.image = UIImage(systemName: "person.crop.circle.badge.plus")
//    }
}
extension SignUpViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userSelectedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profileImgOutlet.image = userSelectedImg
            userSelectImageToStorage = userSelectedImg
        }
        dismiss(animated: true, completion: nil)
    }
}
