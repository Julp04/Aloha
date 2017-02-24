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


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBAction func loginAction(_ sender: Any) {
        loginUser()
    }
    @IBOutlet weak var loginButton: UIButton!
    var ref: FIRDatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()

    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
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
    override func viewDidAppear(_ animated: Bool) {
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        setUpTextField(emailField)
        setUpTextField(passwordField)
        
        self.loginButton.layer.cornerRadius = 5.0
        self.view.backgroundColor = UIColor.qnPurple
    }
    
    func loginUser()
    {
        if Reachability.isConnectedToInternet() {
            
            showHud("Logging in...")
            
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
                    
        
                }else {
                    self.segueToMainApp()
                }
                
                self.hideHud()
            })
            
            
        }
    }
    
    //MARK: Alerts
    
    fileprivate func showConnectionAlert()
    {
        RKDropdownAlert.title("No Internet Connection", message: "Please connect to the interwebs and try agian", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
    }
    
    
    fileprivate func segueToMainApp()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Login, sender: self)
    }
    
    
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
    
    
    //MARK: - UI Setup
    
    func setUpTextField(_ textField:SkyFloatingLabelTextFieldWithIcon) {
        textField.delegate = self
        
        
        if textField == emailField {
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f007}"
        }else {
            passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            passwordField.iconText = "\u{f023}"
        }
        
        textField.selectedIconColor = UIColor.white
        textField.iconMarginBottom = -2.0
        
    }
    
    //MARK: - Delegates
    
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
        }
        
        if textField == emailField {
            emailField.errorMessage = ""
        }
        
        return true
    }

    
    //MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}
