//
//  SettingsViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import Parse
import ParseTwitterUtils

class SettingsViewController: UITableViewController {

    
    @IBOutlet weak var quickAddSwitch: UISwitch! {
        didSet {
            quickAddSwitch.isOn = Defaults["QuickScan"].bool!
        }
    }
    @IBOutlet weak var webpageSwitch: UISwitch! {
        didSet {
            webpageSwitch.isOn = Defaults["AutomaticURLOpen"].bool!
        }
    }
    //MARK: IBActions
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func webPageSwitchAction(_ sender: UISwitch) {
        Defaults["AutomaticURLOpen"] = sender.isOn
        Defaults.synchronize()
    }
    @IBAction func quickAddSwitchAction(_ sender: AnyObject) {
       
        let switchControl = sender as! UISwitch
        Defaults["QuickScan"] = switchControl.isOn
        Defaults.synchronize()
    }
    //MARK: LifeCycle Methods
    
    override func viewWillAppear(_ animated: Bool){
        self.navigationItem.title = "Settings"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurpleColor()
    }
    
    //MARK: Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:showLogoutAlert()
            case 1:break
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
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    //MARK: Cell Actions
    
    fileprivate func showLogoutAlert()
    {
        let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            User.logOut()
            
            self.performSegue(withIdentifier: SegueIdentifiers.Logout, sender: self)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    





}
