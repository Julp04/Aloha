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
    
    var userInfo = UserInfo()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeContinueStatus(enabled: false)
        
           self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        firstnameField.becomeFirstResponder()
        UIApplication.shared.setStatusBarHidden(true, with: .none)

        
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
            changeContinueStatus(enabled: false)
        }else {
            changeContinueStatus(enabled: true)
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
    
    
    func changeContinueStatus(enabled:Bool)
    {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0: 0.5
        
    }
    
    override var prefersStatusBarHidden: Bool {
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
