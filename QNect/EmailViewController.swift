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

class EmailViewController: UIViewController {

    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f0e0}"
            emailField.iconMarginBottom = -2.0
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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            
        }
    }
    
}
