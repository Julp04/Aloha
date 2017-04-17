//
//  EmailViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/27/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import JPLoadingButton
import Firebase
import ReachabilitySwift

class EmailViewController: UIViewController {
    
    //MARK: Properties
    
    var userInfo: UserInfo?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Outlets

    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f0e0}"
            emailField.iconMarginBottom = -2.0
            emailField.delegate = self
        }
    }
    @IBOutlet weak var continueButton: JPLoadingButton! {
        didSet {
            continueButton.enable = false
        }
    }
    
    //MARK: Actions
    
    @IBAction func continueAction(_ sender: Any) {
        continueSignup()
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
    
    //MARK: Functionality
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }

    func continueSignup()
    {
        guard continueButton.enable else {
            return
        }
        
        guard Reachability.isConnectedToInternet() else {
            AlertUtility.showConnectionAlert()
            return
        }
        
        continueButton.startLoadingAnimation()
        
        FIRAuth.auth()?.fetchProviders(forEmail: emailField.text!) { some, error in
            guard error == nil else {
                print(error!)
                self.continueButton.stopLoadingAnimation()
                return
            }
            
            guard some == nil else {
                self.emailField.errorMessage = "Email already registered"
                self.continueButton.stopLoadingAnimation()
                return
            }
            
            print("No active email")
            //No active email continue to register
            self.userInfo?.email = self.emailField.text!
            
        
//            self.performSegue(withIdentifier: "ProfileInfo", sender: self.userInfo)
           
        

                FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.userInfo!.password!) {user, error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    

                    QnClient.sharedInstance.setUserInfo(userInfo: self.userInfo!)
                    FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.userInfo!.password!) {user, error in
                        
                        guard error == nil else {
                            print(error!)
                            return
                        }
                        self.performSegue(withIdentifier: "ProfileInfo", sender: self.userInfo)
                        self.continueButton.stopLoadingAnimation()
                    }
                }
        }
        
        
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let profileInfoVC = segue.destination as? EditProfileViewController {
            profileInfoVC.configureViewController(userInfo: self.userInfo!)
        }
    }
    
}

extension EmailViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.emailField.errorMessage = ""
        var email = emailField.text
        
        if string == "" {
            email?.characters.removeLast()
        }else {
            email?.characters.append(string.characters.first!)
        }
    
        continueButton.enable = (email?.isValidEmail)! ? true : false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueSignup()
        return true
    }
}
