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

class EmailViewController: UIViewController, UITextFieldDelegate {

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
            changeContinueStatus(enabled: false)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        emailField.becomeFirstResponder()
    }
    
    var userInfo:UserInfo?
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }


    @IBAction func continueAction(_ sender: Any) {
        continueSignup()
    }

    func changeContinueStatus(enabled:Bool)
    {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0: 0.5
        
    }
    
    
    func continueSignup()
    {
        
        if continueButton.isEnabled {
            
            if Reachability.isConnectedToInternet() {
                
                    FIRAuth.auth()?.fetchProviders(forEmail: emailField.text!, completion: { (some, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            if some == nil {
                                print("No active email")
                                //No active email continue to register
                                self.userInfo?.email = self.emailField.text!
                                
//                                FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.userInfo!.password!, completion: { (user, error) in
//                                    if error != nil {
//                                        print(error!)
//                                    }else {
//                                        
//                                        self.performSegue(withIdentifier: "ProfileInfo", sender: self.userInfo)
//                                    }
//                                })
//                                
                                
                                //Testing Purposes
                                self.performSegue(withIdentifier: "ProfileInfo", sender: self.userInfo)
                                
                                
                            }else{
                                print("Email already exists")
                                self.emailField.errorMessage = "Email already registered"
                            }
                        }
                    })
            }
            }else {
                AlertUtility.showConnectionAlert()
            }
        
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        self.emailField.errorMessage = ""
        
        var email = emailField.text
        
        if string == "" {
            email?.characters.removeLast()
        }else {
            email?.characters.append(string.characters.first!)
        }
        
        if (email?.contains("@"))! && (email?.characters.count)! >= 3 {
            changeContinueStatus(enabled: true)
        }else {
            changeContinueStatus(enabled: false)
        }
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueSignup()
        return true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let profileInfoVC = segue.destination as? ProfileInfoViewController {
            profileInfoVC.configureViewController(userInfo: self.userInfo!)
        }
    }
    
}
