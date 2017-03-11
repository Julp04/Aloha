//
//  LoginViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import MBProgressHUD
import ReachabilitySwift
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RKDropdownAlert
import FCAlertView
import Fabric
import TwitterKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import JPLoadingButton


class LoginViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f007}"
            
            emailField.selectedIconColor = UIColor.white
            emailField.iconMarginBottom = -2.0
        }
    }
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            passwordField.iconText = "\u{f023}"
            
            passwordField.selectedIconColor = UIColor.white
            passwordField.iconMarginBottom = -2.0
        }
    }
    @IBOutlet weak var loginButton: JPLoadingButton! {
        didSet {
            loginButton.enable = false
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var ref: FIRDatabaseReference!
    
    @IBAction func loginAction(_ sender: Any) {
        loginUser()
    }
    @IBAction func forgotPasswordAction(_ sender: Any) {
        forgotPassword()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
    }
    
    
    
  
    override func viewDidAppear(_ animated: Bool) {
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.view.backgroundColor = UIColor.qnPurple
    }
    
    func loginUser()
    {
        
        if Reachability.isConnectedToInternet() {
            if !(emailField.text?.contains("@"))! {
                //User is signing in with username not email
                //Fetch email from username and sign in with that
                
                let ref = FIRDatabase.database().reference()
                
                let usernamesRef = ref.child("usernames")
                let currentTypedUserRef = usernamesRef.child(emailField.text!)
                
                currentTypedUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                       //todo: Login with username
                    }
                })

            }else {
                //User is logging in with email
                
                self.loginButton.startLoadingAnimation()
                
                FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                    if error != nil {
                        
                        if error!.localizedDescription.contains("Network") {
                            RKDropdownAlert.title("Network Error", message: "Check your network settings and try again", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                            
                            
                        }else {
                            if !(self.emailField.text?.contains("@"))! || self.emailField.text == nil {
                                self.emailField.errorMessage = "Invalid Email"
                            }else {
                                self.passwordField.errorMessage = "Invalid Password"
                            }
                        }
                        
                        self.loginButton.stopLoadingAnimation()
                        
                    }else {
                        
                        //todo: Fix storyboard animation
                        let mainVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
                        self.loginButton.startFinishAnimationWith(currentVC: self, viewController: mainVC)
                    }
                })
            }
        }
        
    }
    
    
    //todo: Get new hud
    func showHud(_ title:String?)
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        if let title = title {
            hud.label.text = title
        }
    }
    
    func hideHud()
    {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func forgotPassword()
    {
        var hitReset = 0
        
        var email = ""
        let alert = FCAlertView()
        
        alert.addTextField(withPlaceholder: "Email") { (string) in
            email  = string!
            
            if hitReset == 1 {
                if email != "" {
                    FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                        if error != nil {
                            RKDropdownAlert.title("\(email) is not a registered user", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                        }else {
                            RKDropdownAlert.title("Password Reset Email Sent!", message: "Check your inbox for a link to reset", backgroundColor: UIColor.qnGreen, textColor: UIColor.white)
                        }
                    })
                }else {
                    RKDropdownAlert.title("Email cannot be blank", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                }
            }
        }
        
        alert.addButton("Cancel", withActionBlock: {
            hitReset = 0
        })
        alert.doneActionBlock {
            hitReset = 1
        }
        alert.colorScheme = UIColor.qnPurple
        alert.showAlert(inView: self, withTitle: "Reset Password", withSubtitle: "Please enter your email and we'll send a link to reset it!", withCustomImage: #imageLiteral(resourceName: "lock"), withDoneButtonTitle: "Reset Password", andButtons: nil)
    }
    
    
    //MARK: Delegates
    
    //MARK:Touches Delegates
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else {
            loginUser()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == passwordField {
            passwordField.errorMessage = ""
            
            var password = passwordField.text
            
            if string == "" {
                password?.characters.removeLast()
            }else {
                password?.characters.append(string.characters.first!)
            }
            
            if (password?.characters.count)! > 2 {
                loginButton.enable = true
            }else {
                loginButton.enable = false
            }
        }
        
        if textField == emailField {
            self.emailField.errorMessage = ""
            
            if var email = emailField.text {
                if string == "" {
                    email.characters.removeLast()
                }else {
                    email.characters.append(string.characters.first!)
                }
                
                if email.isValidEmail {
                    loginButton.enable = true
                }else {
                    loginButton.enable = false
                }
            }
        }
        
        return true
    }
}

//MARK: Extensions

extension String {
    
    var isValidEmail:Bool {
        get {
            let email = self
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            
            return emailTest.evaluate(with: email)
        }
    }
}

extension JPLoadingButton {
    var enable:Bool {
        get {
            return self.enable
        }
        set {
            self.isEnabled = enable
            self.alpha  = enable ? 1.0 : 0.5
        }
    }
}
