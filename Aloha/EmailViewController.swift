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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        emailField.becomeFirstResponder()
        emailField.textColor = .main
        emailField.selectedTitleColor = .main
        emailField.selectedLineColor = .main
        emailField.selectedIconColor = .main
        
        continueButton.normalBackgroundColor = .main
        continueButton.highlightedBackgroundColor = .alohaGreen
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
            
            //No active email continue to register
            self.userInfo?.email = self.emailField.text!
           
                FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.userInfo!.password!) {user, error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    
                    FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.userInfo!.password!) {user, error in
                        guard error == nil else {
                            print(error!)
                            return
                        }
                        
                         QnClient.sharedInstance.setUserInfo(userInfo: self.userInfo!, user: user!)
                        
                        self.performSegue(withIdentifier: "ProfileInfo", sender: self.userInfo)
                        self.continueButton.stopLoadingAnimation()
                    }
                }
        }
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let profileInfoVC = segue.destination as? AddProfileInfoViewController {
            profileInfoVC.configureViewController(userInfo: self.userInfo!)
        }
    }
}

extension EmailViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.emailField.errorMessage = ""
        var email = emailField.text
        
        guard email != "" else {
            return true
        }
        
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

extension EmailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
