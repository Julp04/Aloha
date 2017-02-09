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


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var isLinkingWithTwitter = false
    
    var ref: FIRDatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        
    }
    
    @IBAction func twitterLoginAction(_ sender: AnyObject) {
        loginWithTwitter()
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
                    
                   RKDropdownAlert.title("Login failed", message: error!.localizedDescription, backgroundColor: UIColor.qnTealColor(), textColor: UIColor.white)
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
        RKDropdownAlert.title("No Internet Connection", message: "Please connect to the interwebs and try agian", backgroundColor: UIColor.qnRedColor(), textColor: UIColor.white)
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
                    signupVC.configureViewController(isLinkingWithTwitter)
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
