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

class PasswordViewController: UIViewController {
    
    //MARK: Properties
    
    var userInfo: UserInfo?
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK: Outlets
    
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            self.passwordField.iconText = "\u{f023}"
            passwordField.iconMarginBottom = -2.0
            passwordField.delegate = self
        }
    }
    @IBOutlet weak var continueButton: JPLoadingButton!
    
    //MARK: Actions
    
    @IBAction func continueAction(_ sender: Any) {
        continueSignup()
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.enable = false

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        passwordField.becomeFirstResponder()
    }

    //MARK: Functionality
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    

    func continueSignup()
    {
        if continueButton.isEnabled {
            self.userInfo?.password = passwordField.text
            self.performSegue(withIdentifier: "EmailSegue", sender: self)
        }
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let emailVC = segue.destination as? EmailViewController {
            emailVC.configureViewController(userInfo: userInfo!)
        }
    }
}


extension PasswordViewController: UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var password = passwordField.text
        
        if string == "" {
            password?.characters.removeLast()
        }else {
            password?.characters.append(string.characters.first!)
        }
        
        continueButton.enable = (password?.characters.count)! >= 6 ? true : false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueSignup()
        return true
    }
}
