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

class SettingsViewController: UITableViewController {


    //MARK: Constants
    
    //MARK: Properties
    
    //MARK: Outlets
    
    //MARK: Actions
    
  
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black,
                                    NSFontAttributeName : UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)]
        navigationController?.navigationBar.tintColor = .black
        UIApplication.shared.statusBarStyle = .default
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
            
        default:break
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
