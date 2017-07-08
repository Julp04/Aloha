//
//  SettingsViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import FirebaseAuth
import FCAlertView
import RKDropdownAlert
import Firebase


class SettingsViewController: UITableViewController {


    //MARK: Constants
    let kContactSupport = "support@sayaloha.io"
    
    //MARK: Properties
    
    //MARK: Outlets
    
    @IBOutlet weak var privateModeSwitch: UISwitch!
    //MARK: Actions
    
    @IBAction func privateModeChanged(_ sender: Any) {
        let privateModeSwitch = sender as! UISwitch
    
        QnClient.sharedInstance.updatePrivateMode(isPrivate: privateModeSwitch.isOn)
    }
  
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QnClient.sharedInstance.currentUser { (user) in
            self.privateModeSwitch.isOn = user.isPrivate
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        MainController.transitionManager.isEnabled = false
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white,
                                    NSFontAttributeName : UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)]
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //MARK: Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:showLogoutAlert()
            case 1:resetPassword()
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0: break
            default:break
            }
        case 2:
            switch indexPath.row {
            case 0:
                //Privacy Policy
               
                let value = FIRRemoteConfig.remoteConfig().configValue(forKey: "privacypolicyurl")
                if let urlString = value.stringValue, let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
                break
            case 1:
                let value = FIRRemoteConfig.remoteConfig().configValue(forKey: "termsurl")
                if let urlString = value.stringValue, let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
                break
            case 2:
                let value = FIRRemoteConfig.remoteConfig().configValue(forKey: "supporturl")
                if let urlString = value.stringValue, let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
                break
            case 3:
                let value = FIRRemoteConfig.remoteConfig().configValue(forKey: "thirdpartyurl")
                if let urlString = value.stringValue, let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
                break
            case 4:
                //Delete account
                showDeleteAccountAlert()
                break;
            default:
                break
            }
        default:break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "Delete your account?", message: "Deleting your account will completely remove all user data. Is this really good-bye? 😢", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
            
            if let password = alert.textFields?[0].text {
                let currentUser = FIRAuth.auth()!.currentUser!
                FIRAuth.auth()?.signIn(withEmail: currentUser.email!, password: password, completion: { (user, error) in
                    if error != nil {
                        self.showIncorrectPasswordAlert()
                    }else {
                        QnClient.sharedInstance.deleteCurrentUser(completion: { (result) in
                            switch result {
                            case .failure(let error):
                                //Unable to delete your account
                                print(error)
                                break
                            case .success(nil):
                                self.performSegue(withIdentifier: "LogoutSegue", sender: self)
                                break
                            default:
                                break
                            }
                        })
                    }
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func showIncorrectPasswordAlert() {
        let alert = UIAlertController(title: "Unable to delete account", message: "Password entered was incorrect", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showUnableToDeleteAccountAlert() {
        let alert = UIAlertController(title: "Oops we were unable to delete your account", message: "Please contact us at \(kContactSupport)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
  
    
    
    //MARK: Cell Actions
    
    fileprivate func showLogoutAlert()
    {
        let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in

            QnClient.sharedInstance.signOut()

            self.performSegue(withIdentifier: "LogoutSegue", sender: self)
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func resetPassword()
    {
        let alert = FCAlertView()
        alert.addButton("Cancel") {}
        alert.doneActionBlock {
            let email = FIRAuth.auth()!.currentUser!.email!
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                if error != nil {
                    RKDropdownAlert.title("Something went wrong", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                }else {
                    RKDropdownAlert.title("Email Sent!", message: "Check your inbox for a link to reset password", backgroundColor: UIColor.qnGreen, textColor: UIColor.white)
                }
            })

        }
        
        alert.colorScheme = UIColor.main
        alert.showAlert(inView: self, withTitle: "Reset Password", withSubtitle: "We'll send you a link to your email to reset your password", withCustomImage: #imageLiteral(resourceName: "lock_icon"), withDoneButtonTitle: "Reset Password", andButtons: nil)
    }
}
