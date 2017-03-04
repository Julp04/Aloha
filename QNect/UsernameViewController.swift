//
//  UsernameViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/27/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import ReachabilitySwift
import Firebase
import RKDropdownAlert
import JPLoadingButton

class UsernameViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var usernameField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            usernameField.iconFont = UIFont.fontAwesome(ofSize: 15)
            usernameField.iconText = "\u{f007}"
            usernameField.iconMarginBottom = -2.0
            usernameField.delegate = self
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
        
        usernameField.becomeFirstResponder()

        
    }
    
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
        
            if Reachability.isConnectedToInternet() {
                
                doesUsernameExist(completion: { (usernameExists) in
                    if usernameExists {
                        self.usernameField.errorMessage = "Username already exists"
                        self.changeContinueStatus(enabled: false)
                    }else {
                        self.usernameField.errorMessage = ""
                        self.changeContinueStatus(enabled: true)
                        self.userInfo?.userName = self.usernameField.text
                        
                        self.performSegue(withIdentifier: "PasswordSegue", sender: self)
                    }
                })
            }else {
                
                AlertUtility.showConnectionAlert()
            }
        }
        
        
    }
    
    
    func doesUsernameExist(completion: @escaping (Bool) -> Void)
    {
        let ref = FIRDatabase.database().reference()
        
        
        let usernamesRef = ref.child("usernames")
        let currentTypedUserRef = usernamesRef.child(usernameField.text!)
        
        currentTypedUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(true)
            }else {
                completion(false)
            }
        })
       
    }
    
    func changeContinueStatus(enabled:Bool)
    {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0: 0.5
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let passwordVC = segue.destination as? PasswordViewController {
            passwordVC.configureViewController(userInfo: userInfo!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.usernameField.errorMessage = ""
        
        var username = usernameField.text
        
        if string == "" {
            username?.characters.removeLast()
        }else {
            username?.characters.append(string.characters.first!)
        }
        
        if (username?.characters.count)! > 3 {
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

}
