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

class NameViewController: UIViewController {
    

    //MARK: Properties
    
    var userInfo = UserInfo()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Outlets
    
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
    
    //MARK: Actions
    
    @IBAction func continueAction(_ sender: Any) {
        continueWithSignup()
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.enable = false
        
        firstnameField.becomeFirstResponder()
        firstnameField.textColor = .main
        firstnameField.selectedTitleColor = .main
        firstnameField.selectedLineColor = .main
        
        lastnameField.textColor = .main
        lastnameField.selectedTitleColor = .main
        lastnameField.selectedLineColor = .main
        
        continueButton.normalBackgroundColor = .main
        continueButton.highlightedBackgroundColor = .alohaGreen
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.main
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }

   
    //MARK: Functionality
    
    func continueWithSignup()
    {
        userInfo.firstName = firstnameField.text
        userInfo.lastName = lastnameField.text
        
        self.performSegue(withIdentifier: "UsernameSegue", sender: self)
        
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let usernameVC = segue.destination as? UsernameViewController {
            usernameVC.configureViewController(userInfo: userInfo)
        }
    }
}

extension NameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var first = firstnameField.text
        var last = lastnameField.text
        
        
        if textField == firstnameField {
            if string == "" {
                first?.characters.removeLast()
            }else {
                first?.characters.append(string.characters.last!)
            }
        }
        
        if textField == lastnameField {
            if string == "" {
                last?.characters.removeLast()
            }else {
                last?.characters.append(string.characters.last!)
            }
        }

        
        guard (last?.characters.count)! >= 1 else {
            self.continueButton.enable = false
            return true
        }
        
        guard (first?.characters.count)! >= 1 else {
            self.continueButton.enable = false
            return true
        }
        
        continueButton.enable = true
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard textField == firstnameField else {
            continueWithSignup()
            return true
        }
        
        lastnameField.becomeFirstResponder()
        return true
    }
}

