//
//  PasswordViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/27/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import JPLoadingButton

class PasswordViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            self.passwordField.iconText = "\u{f023}"
            passwordField.iconMarginBottom = -2.0
            passwordField.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.enable = false

       self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        passwordField.becomeFirstResponder()
        
    }

  
    
    @IBOutlet weak var continueButton: JPLoadingButton!
    
    var userInfo:UserInfo?
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    
   
    @IBAction func continueAction(_ sender: Any) {
        continueSignup()
    }
    
    func continueSignup()
    {
        if continueButton.isEnabled {
            
            self.userInfo?.password = passwordField.text
            
            self.performSegue(withIdentifier: "EmailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let emailVC = segue.destination as? EmailViewController {
            emailVC.configureViewController(userInfo: userInfo!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var password = passwordField.text

        if string == "" {
            password?.characters.removeLast()
        }else {
          password?.characters.append(string.characters.first!)
        }
        
        
        if (password?.characters.count)! >= 6 {
            continueButton.enable = true
        }else {
            continueButton.enable = false
        }
        
        
        

        return true
    }

  
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueSignup()
        
        return true
    }
    


    

    
}
