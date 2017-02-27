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

class UsernameViewController: UIViewController {

    @IBOutlet weak var usernameField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            usernameField.iconFont = UIFont.fontAwesome(ofSize: 15)
            usernameField.iconText = "\u{f007}"
            usernameField.iconMarginBottom = -2.0
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.layer.cornerRadius = 5.0
            continueButton.backgroundColor = UIColor.qnPurple
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
        self.userInfo?.userName = usernameField.text
        
        self.performSegue(withIdentifier: "PasswordSegue", sender: self)
        
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let passwordVC = segue.destination as? PasswordViewController {
            passwordVC.configureViewController(userInfo: userInfo!)
        }
    }


}
