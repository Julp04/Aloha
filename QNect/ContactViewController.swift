//
//  ContactViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import MessageUI
import Cartography
import ReachabilitySwift
import RKDropdownAlert
import Firebase


class ContactViewController: UITableViewController,MFMessageComposeViewControllerDelegate {

    var contact:User?
    var contactModel:ContactModel? = nil
    
    let kCellHeight:CGFloat = 70.0
    let kLargeHeaderHeight:CGFloat = 150.0
    let kSmallHeaderHeight:CGFloat = 10.0
    let kNumberOfSections = 3
    let kProfileImageBorderWidth:CGFloat = 2.0
    let kAddButtonWidth: CGFloat = 30.0
    let kTrailingConstraint:CGFloat = 20
    let kTopConstraint:CGFloat = 10
    let kToastFontSize:CGFloat = 15
    
    var contactImage:UIImage?
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
  
    
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveConnectionAction(_ sender: AnyObject)
    {
        followUser()
        
    }
    @IBAction func sendMessageToContact(_ sender: AnyObject)
    {
        sendMessage()
        
       
    }
    @IBAction func callContact(_ sender: AnyObject)
    {
        makeCall()
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        
        tableView.reloadData()
    }
    
 
    
    func configureViewController(_ contact:User)
    {
        self.contact = contact
        self.contactModel = ContactModel(contact: contact)
    }
    
 


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return kNumberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 0
        case 1:
            return 1
        case 2:
            return (contactModel?.numberOfSocialAccounts())!
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")
            
        
            return cell!
        }else {
            return UITableViewCell(frame: CGRect.zero)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return kLargeHeaderHeight
        }else {
            return kCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section
        {
        case 0:
            
            if contact?.profileImage == nil {
                if Reachability.isConnectedToInternet() {
                    QnClient.sharedInstance.getProfileImageForUser(user: contact!, completion: { (profileImage, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            
                        }
                    })
                }
            }else {
               
            }
            
            
            return view
        default:
            return nil
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                if let screenName = contact?.twitterAccount?.screenName {
                    let url = URL(string: "twitter://user?screen_name=\(screenName)")
                    UIApplication.shared.openURL(url!)
                
                }
            case 1:
                break
            default:
                break
            }
            
        }
    }
    
    //Header Height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return kLargeHeaderHeight
        } else {
            return kSmallHeaderHeight
        }
    }
    
    
    //MARK: - Contact Actions
    
    func addContact()
    {
        
    }
    
    func followUser()
    {
        

        let currentUser = FIRAuth.auth()!.currentUser!
        
        databaseRef.child("users").child(currentUser.uid).observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            
            
            self.databaseRef.child("following").child(user.uid).child(self.contact!.uid).setValue(["firstName":self.contact!.firstName, "lastName":self.contact!.lastName])
            
            
            self.databaseRef.child("followers").child(self.contact!.uid).child(currentUser.uid).setValue(["firstName":user.firstName, "lastName": user.lastName])
        })
       
        
        
        RKDropdownAlert.title("Woo!", message: "You are now following \(contact!.firstName!) \(contact!.lastName!)", backgroundColor: UIColor.qnBlue, textColor: UIColor.white)
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
  
    
    func followContactOnTwitter()
    {
        let screenName = contact!.twitterAccount?.screenName
        
        
        TwitterClient.client.isUserLinkedWithTwitter { (isLinked) in
            if isLinked {
                TwitterClient.client.followUserWith(screenName: screenName!) { (error) in
                    if error != nil {
                        RKDropdownAlert.title("Oops", message: error!.localizedDescription, backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                    }else {
                        RKDropdownAlert.title("You are now following \(screenName!) on Twitter!", backgroundColor: UIColor.twitter, textColor: UIColor.white)
                    }
                }
            }else {
                
            }
        }
    }
    
    func sendMessage()
    {
        if let phoneNumber = contact?.socialPhone {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.recipients = ["\(phoneNumber)"]
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: false, completion: nil)
        }
        
    }
    
    func makeCall()
    {
        if let phoneNumber = contact?.socialPhone {
            let phone = "tel://\(phoneNumber)";
            let url = URL(string:phone)!;
            UIApplication.shared.openURL(url);
        }
    }
    
    
    //MARK: - Alerts
    
    func showCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
                                                    message: "You must give the app permission to add the contact first.",
                                                    preferredStyle: .alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .default,
            handler: { action in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    
    
    func showContactAddedAlert()
    {
        
        RKDropdownAlert.title("Wooo!", message: "You saved \(contact!.firstName!) \(contact!.lastName!) to your contacts!", backgroundColor: UIColor.qnTeal, textColor: UIColor.white)
    }
    

    
    
    //MARK:Message Delegates
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //MARK: Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    



}
