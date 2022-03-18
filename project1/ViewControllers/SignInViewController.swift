//
//  SignInViewController.swift
//  project1
//
//  Created by فاطمه المطر on 12/06/2021.
//

import UIKit
import JGProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var SignInBtnOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        SignInBtnOutlet.backgroundColor = UIColor.lightGray
        SignInBtnOutlet.isEnabled = false
        textFields ()
        
    }
    
    //to keep user signed in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if API.user.currentUser != nil {
            self.performSegue(withIdentifier: "signIn_Identifier", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "أهلًا بك مرةً أخرى.."
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 5.0)
    }
    
    @objc func textFields (){
        emailOutlet.addTarget(self, action: #selector(SignInViewController.textFieldsIsEmpty), for: UIControl.Event.editingChanged)
        passwordOutlet.addTarget(self, action: #selector(SignInViewController.textFieldsIsEmpty), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldsIsEmpty () {
        guard let email = emailOutlet.text , !email.isEmpty, let password = passwordOutlet.text , !password.isEmpty else {
            SignInBtnOutlet.backgroundColor = UIColor.lightGray
            SignInBtnOutlet.isEnabled = false
            return
        }
        SignInBtnOutlet.backgroundColor = UIColor.systemYellow
        SignInBtnOutlet.isEnabled = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        Authentication.SignIn(email: emailOutlet.text!, password: passwordOutlet.text!) {
            //note: اعمل لي انتقال اذا كان المستخدم موجود في قاعدة البيانات
            
            self.performSegue(withIdentifier: "signIn_Identifier", sender: nil)
            self.cleanTextFields()

        } IfSignInError: { (error) in
            let hud = JGProgressHUD()
            hud.textLabel.text = "خطأ في بياناتك ! "
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    func cleanTextFields(){
        emailOutlet.text = ""
        passwordOutlet.text = ""
    }

}
