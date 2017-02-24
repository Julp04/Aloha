//
//  Signup1ViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/24/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField


class Signup1ViewController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.emailField.delegate = self
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f007}"
            emailField.title = "Email"
            emailField.titleColor = UIColor.lightGray
            emailField.selectedTitleColor = UIColor.qnPurple
            emailField.iconMarginBottom = -2.0
            
            
        }
    }
   
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.passwordField.delegate = self
            self.passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            self.passwordField.iconText = "\u{f023}"
            passwordField.iconMarginBottom = -2.0
            
            
        }
    }
    @IBOutlet weak var continueButton: UIButton! {
        didSet{
            continueButton.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.backgroundColor = UIColor.black
            profileImageView.layer.cornerRadius = 50.0
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func continueToNextStep()
    {
        
    }
    
    func changeContinueStatus(enable:Bool)
    {
        
    }
    
    
    //MARK: TextField Delegate
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            self.passwordField.becomeFirstResponder()
        }else {
            continueToNextStep()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            if let email = emailField.text {
                if !email.contains("@") {
                        emailField.errorMessage = "Invalid Email"
                }else {
                    emailField.errorMessage = ""
                }
            }
        }
        
        if textField == passwordField {
            if let password = passwordField.text {
                if password.characters.count < 5 {
                    passwordField.errorMessage = "Must be more than 6 characters"
                }else {
                    passwordField.errorMessage = ""
                    
                }
            }
        }
        
        
        
        return true
    }
    
    

    

}
