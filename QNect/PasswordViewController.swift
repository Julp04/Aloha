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
        changeContinueStatus(enabled: false)

       self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        passwordField.becomeFirstResponder()
        
    }

  
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.layer.cornerRadius = 5.0
            continueButton.backgroundColor = UIColor.qnPurple
        }
    }
    var userInfo:UserInfo?
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    
   
    @IBAction func continueAction(_ sender: Any) {
        self.userInfo?.password = passwordField.text
        
        self.performSegue(withIdentifier: "EmailSegue", sender: self)
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
        
        checkPassword(password: password!)
        

        return true
    }
    
    func checkPassword(password:String)
    {
        if password.characters.count >= 6 {
            changeContinueStatus(enabled: true)
        }else {
            changeContinueStatus(enabled: false)
        }
    }
    

    func isValidPassword(password:String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,15}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func changeContinueStatus(enabled:Bool)
    {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0: 0.5
        
    }
    


    

    
}
