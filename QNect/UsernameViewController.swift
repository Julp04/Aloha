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

class UsernameViewController: UIViewController{

    //MARK: Properties
    
    var userInfo: UserInfo?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Outlets
    
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
        
        #if UI
            self.userInfo = UserInfo.testUser
        #endif
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        usernameField.becomeFirstResponder()
    }
    
    func configureViewController(userInfo: UserInfo)
    {
        self.userInfo = userInfo
    }
    
    //MARK: Functionality

    func continueSignup()
    {
        if continueButton.isEnabled {
        
            if Reachability.isConnectedToInternet() {
                continueButton.startLoadingAnimation()
                
                doesUsernameExist(completion: { (usernameExists) in
                    if usernameExists {
                        self.usernameField.errorMessage = "Username already exists"
                        self.continueButton.enable = false
                    }else {
                        self.usernameField.errorMessage = ""
                        self.continueButton.enable = true
                        self.userInfo?.userName = self.usernameField.text
                        
                        self.performSegue(withIdentifier: "PasswordSegue", sender: self)
                    }
                    self.continueButton.stopLoadingAnimation()
                })
            }else {
                
                AlertUtility.showConnectionAlert()
            }
        }
    }
    
    
    /// Checks to see if the username exists in the database or not
    ///
    /// - Parameter completion: completion block with bool value whether or not the username exists
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
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let passwordVC = segue.destination as? PasswordViewController {
            passwordVC.configureViewController(userInfo: userInfo!)
        }
    }
}


extension UsernameViewController: UITextFieldDelegate  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.usernameField.errorMessage = ""
        
        var username = usernameField.text
        
        
        
        if (username?.characters.count)! > 0 {
            if string == "" {
                username?.characters.removeLast()
            }else {
                username?.characters.append(string.characters.first!)
        }
        }
        
        continueButton.enable = (username?.characters.count)! > 3 ? true : false
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueSignup()
        return true
    }
    
}
