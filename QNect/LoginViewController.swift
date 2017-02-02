//
//  LoginViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import CRToast
import ParseTwitterUtils


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var isLinkingWithTwitter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func twitterLoginAction(_ sender: AnyObject) {
        loginWithTwitter()
    }
    override func viewDidAppear(_ animated: Bool) {
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        setUpTextField(usernameField)
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
            User.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { (user, error) -> Void in
                if user != nil {
                    self.segueToMainApp()
                }else {
                    if let code = error?.code {
                        if code == PFErrorCode.errorObjectNotFound.rawValue {
                            self.incorrectParameters()
                            self.hideHud()
                        }
                    }
                    self.hideHud()
                }
            }
        }else {
            self.hideHud()
            showConnectionAlert()
        }
    }
    
    func loginWithTwitter()
    {
        if Reachability.isConnectedToInternet()
        {
            self.showHud("Logging in...")
            PFTwitterUtils.logIn {
                (user: PFUser?, error: NSError?) -> Void in
                if let user = user {
                    if user.isNew {
                        self.isLinkingWithTwitter = true
                        self.segueToLinkUser()
                    } else {
                        self.hideHud()
                        self.segueToMainApp()
                    }
                }else{
                    print("Twitter cancelled")
                    self.hideHud()
                }
            }
        }
        else {
            self.hideHud()
            showConnectionAlert()
        }
    }
    
    
    //MARK: Alerts
    
    fileprivate func showConnectionAlert()
    {
        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage(AlertMessages.Internet, withColor: nil), completionBlock: { () -> Void in
        })
    }
    
    /**
     Handles what happens when username or password that is entered is invalid
     */
    fileprivate func incorrectParameters()
    {
        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage(AlertMessages.IncorrectParams, withColor: UIColor.gray), completionBlock: { () -> Void in
        })
    }
    
    //MARK:Segues
    
    fileprivate func segueToLinkUser()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Signup, sender: self)
    }
    
    fileprivate func segueToMainApp()
    {
        self.performSegue(withIdentifier: SegueIdentifiers.Login, sender: self)
        
        let installation = PFInstallation.current()!
        installation["user"] = User.current()
        installation["username"] = User.current()!.username!
        installation.saveInBackground()
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
        if textField == usernameField {
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
