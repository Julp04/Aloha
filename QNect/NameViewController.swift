//
//  NameViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/27/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import JPLoadingButton

class NameViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var firstnameField: SkyFloatingLabelTextField! {
        didSet {
            firstnameField.delegate = self
        }
    }
    @IBOutlet weak var lastnameField: SkyFloatingLabelTextField! {
        didSet {
            lastnameField.delegate = self
        }
    }
    @IBOutlet weak var continueButton: JPLoadingButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var userInfo = UserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.enable = false
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        firstnameField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    @IBAction func continueAction(_ sender: Any) {
        continueWithSignup()
    }
    
    func continueWithSignup()
    {
        userInfo.firstName = firstnameField.text
        userInfo.lastName = lastnameField.text
        
        self.performSegue(withIdentifier: "UsernameSegue", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let usernameVC = segue.destination as? UsernameViewController {
            usernameVC.configureViewController(userInfo: userInfo)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        
        if (firstnameField.text?.characters.count)! <= 1 || (lastnameField.text?.characters.count)! <= 1{
            continueButton.enable = false
        }else {
            continueButton.enable = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstnameField {
            lastnameField.becomeFirstResponder()
        }else {
            continueWithSignup()
        }
        
        return true
    }
}


struct UserInfo
{
    var firstName:String? = nil
    var lastName:String? = nil
    var userName:String? = nil
    var email:String? = nil
    var password:String? = nil
}
