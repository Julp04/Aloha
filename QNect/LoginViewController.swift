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


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            self.signupButton.layer.cornerRadius = 2.0
        }
    }
    var isLinkingWithTwitter = false
    
    var ref: FIRDatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        // Swift
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if let session = session {
                print("signed in as \(session.userName)");
                
                let credential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                print(session.authToken)
                
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // ...
                    if let error = error {
                         print(error)
                        return
                    }else {
                        

                        QnUtilitiy.doesTwitterUserExistsWith(session: session, completion: { (exists) in
                            if exists == true {
                                self.segueToMainApp()
                            }else {
                                self.isLinkingWithTwitter = true
                                self.performSegue(withIdentifier: "SignupSegue", sender: session)
                            }

                        })
                    }
                }
            }else {
                print("error: \(error!.localizedDescription)");
            }
        })
//        logInButton.center = self.twitterView.center
        self.twitterView.addSubview(logInButton)
        
        
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
        
        setUpTextField(emailField)
        setUpTextField(passwordField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func loginUser()
    {
        if Reachability.isConnectedToInternet() {
            
            showHud("Logging in...")
            
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    
                   RKDropdownAlert.title("Login failed", message: error!.localizedDescription, backgroundColor: UIColor.qnTeal, textColor: UIColor.white)
                }else {
                    self.segueToMainApp()
                }
                
                self.hideHud()
            })
            
            
        }
    }
    
    func loginWithTwitter()
    {
        if Reachability.isConnectedToInternet()
        {
        
        }
        else {
            self.hideHud()
            showConnectionAlert()
        }
    }
    
    
    //MARK: Alerts
    
    fileprivate func showConnectionAlert()
    {
        RKDropdownAlert.title("No Internet Connection", message: "Please connect to the interwebs and try agian", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
    }
    
    
    //MARK:Segues
    
    fileprivate func segueToLinkUser()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Signup, sender: self)
    }
    
    fileprivate func segueToMainApp()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Login, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.Signup {
            if let signupVC = segue.destination as? SignupViewController {
                if isLinkingWithTwitter == true {
                    let session = sender as! TWTRSession
                    signupVC.configureViewController(isLinkingWithTwitter, twitterSession: session)
                }
            }
        }
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
    
    func setUpTextField(_ textField:UITextField) {
        if let placeholder = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName:UIColor.white])
        }
        
        textField.delegate = self
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
    
    
    //MARK: - Actions
    

    @IBAction func loginUser(_ sender: AnyObject) {
        loginUser()
    }
    
}
