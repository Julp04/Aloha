//
//  LoginViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
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


class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    var ref: FIRDatabaseReference!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f007}"
            
            emailField.selectedIconColor = UIColor.white
            emailField.iconMarginBottom = -2.0
            
            emailField.delegate = self
        }
    }
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            passwordField.iconText = "\u{f023}"
            
            passwordField.selectedIconColor = UIColor.white
            passwordField.iconMarginBottom = -2.0
            
            passwordField.delegate = self
        }
    }
    @IBOutlet weak var loginButton: JPLoadingButton! {
        didSet {
            loginButton.enable = false
        }
    }
    
    //MARK: Actions
    
    @IBAction func loginAction(_ sender: Any) {
        loginUser()
    }
    @IBAction func forgotPasswordAction(_ sender: Any) {
        forgotPassword()
    }
    
    //MARK: Lifecycle
    
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
        
        
        self.view.backgroundColor = .alohaGreen
        
        emailField.selectedLineColor = .white
        emailField.selectedIconColor = .white
        emailField.selectedTitleColor = .white
        emailField.textColor = .white
        emailField.lineColor = .white
        emailField.titleColor = .white
        emailField.placeholderColor = .white
        emailField.iconColor = .white
        
        passwordField.selectedIconColor = .white
        passwordField.selectedTitleColor = .white
        passwordField.textColor = .white
        passwordField.lineColor = .white
        passwordField.titleColor = .white
        passwordField.placeholderColor = .white
        passwordField.iconColor = .white
        
        loginButton.normalBackgroundColor = .white
        loginButton.highlightedBackgroundColor = .alohaOrange
        loginButton.spinnerColor = .alohaOrange
        
    
        
    }
    
    //MARK: User Interaction
    
    func loginUser()
    {
        
        guard Reachability.isConnectedToInternet() else {
            AlertUtility.showConnectionAlert()
            return
        }
        
        loginButton.startLoadingAnimation()
        guard (emailField.text?.contains("@"))! else {
            loginWithUsername()
            return
        }
        
        //User is loggin in with email
        loginWithEmail()
    }
    
    func loginWithEmail()
    {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!) { user, error in
            
            if error != nil {
                guard self.emailField.text!.isValidEmail else {
                    self.emailField.errorMessage = "Invalid Email"
                    self.loginButton.stopLoadingAnimation()
                    return
                }
                
                self.passwordField.errorMessage = "Invalid Password"
                self.loginButton.stopLoadingAnimation()
            }else {
                //Animate to main view controller
                //todo: Fix storyboard animation
                let mainVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainController") as! UINavigationController
            
                PermissonUtility.isCameraAuthorized(completion: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.loginButton.startFinishAnimationWith(currentVC: self, viewController: mainVC)
                        }
                    }else {
                        DispatchQueue.main.async {
                            let accessCameraController = self.storyboard?.instantiateViewController(withIdentifier: "AccessCameraController") as! AccessCameraController
                            self.present(accessCameraController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func loginWithUsername()
    {
        //User is loggin in with username
        
        let ref = FIRDatabase.database().reference()
        let usernamesRef = ref.child("users")
        usernamesRef.queryOrdered(byChild: "username").queryEqual(toValue: emailField.text!).observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.exists() else {
                self.emailField.errorMessage = "Invalid Username"
                self.loginButton.stopLoadingAnimation()
                return
            }
        
            let values = snapshot.value as! NSDictionary
            let key = values.allKeys.first as! String
        
            
            guard let values2 = values[key] as? NSDictionary else {
                return
            }
            
            guard let email = values2["email"] as? String else {
                return
            }
            
            
                FIRAuth.auth()?.signIn(withEmail: email, password: self.passwordField.text!) {user, error in
                    if error != nil {
                        self.loginButton.stopLoadingAnimation()
                        self.passwordField.errorMessage = "Invalid Password"
                        print(error!)
                    }else {
                        let mainVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainController") as! MainController
                        
                        PermissonUtility.isCameraAuthorized(completion: { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    self.loginButton.startFinishAnimationWith(currentVC: self, viewController: mainVC)
                                }
                            }else {
                                DispatchQueue.main.async {
                                    let accessCameraController = self.storyboard?.instantiateViewController(withIdentifier: "AccessCameraController") as! AccessCameraController
                                    self.present(accessCameraController, animated: true, completion: nil)
                                }
                            }
                        })
                        
                    }
                }
            })

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
        alert.colorScheme = UIColor.main
        alert.showAlert(inView: self, withTitle: "Reset Password", withSubtitle: "Please enter your email and we'll send a link to reset it!", withCustomImage: #imageLiteral(resourceName: "lock_icon"), withDoneButtonTitle: "Reset Password", andButtons: nil)
    }
    
    //MARK:Helper Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        passwordField.errorMessage = ""
        emailField.errorMessage = ""
        var password = passwordField.text
        var email = emailField.text
        
        loginButton.enable = (password?.characters.count)! > 2  ? true : false
        
        if textField == passwordField {
            if string == "" {
                password?.characters.removeLast()
            }else {
                password?.characters.append(string.characters.first!)
            }
        }
        
        if textField == emailField {
            
            guard email != "" else {
                return true
            }
            
            if string == "" {
                email?.characters.removeLast()
            }else {
                email?.characters.append(string.characters.first!)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else {
            loginUser()
        }
        return true
    }
    
}

