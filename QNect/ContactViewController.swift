//
//  ContactViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import ParseTwitterUtils
import CRToast
import Parse
import MessageUI
import Cartography
import ReachabilitySwift



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
    
    var addContactButton:VBFPopFlatButton!
    var addTwitterButton:VBFPopFlatButton!
    var headerCell:ContactHeaderCell?
    
    var contactImage:UIImage?
    
    
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveConnectionAction(_ sender: AnyObject)
    {
        saveConnection()
        
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
        
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurpleColor()
        
  
        headerCell = tableView.dequeueReusableCell(withIdentifier: "ContactHeaderCell") as? ContactHeaderCell
        headerCell!.callButton.isHidden = true
        headerCell!.messageButton.isHidden = true
        if let _ = contact?.socialPhone {
            headerCell!.callButton.isHidden = false
            headerCell!.messageButton.isHidden = false
        }
        
    
        addContactButton = createAddButton(forAction: #selector(ContactViewController.addContact))
        addTwitterButton = createAddButton(forAction: #selector(ContactViewController.followContactOnTwitter))
        
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
            cell.nameLabel.text = contactModel!.nameForContact()
            cell.phoneLabel.text = contactModel!.phoneNumberForContact()
            cell.emailLabel.text = contactModel!.socialEmailForContact()
            
            cell.addSubview(addContactButton)
            constrainButton(addContactButton)

            
            return cell
            
        }else if indexPath.section == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SocialMediaCell") as! SocialMediaCell
            cell.nameLabel.text = contactModel!.socialAccountAtIndex(indexPath.row)
            cell.mediaTypeImageView.image = contactModel!.imageForSocialAccountAtIndex(indexPath.row)
            
            switch contactModel!.socialAccountTypeAtIndex(indexPath.row) {
            case AccountsKey.Twitter:
                cell.addSubview(addTwitterButton)
                constrainButton(addTwitterButton)
            default:
                break
            }
            
            return cell
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
        switch section {
        case 0:
            
            let view  = tableView.dequeueReusableCell(withIdentifier: "ContactHeaderCell") as! ContactHeaderCell
            view.profileImageView.layer.cornerRadius = (view.profileImageView.frame.height)/2
            view.profileImageView.layer.borderColor = UIColor.white.cgColor
            view.profileImageView.layer.masksToBounds = true
            view.profileImageView.layer.borderWidth = kProfileImageBorderWidth
            
            if Reachability.isConnectedToInternet() {
                view.headerCellSpinner.isHidden = false
                view.headerCellSpinner.startAnimating()
                QnUtilitiy.retrieveContactProfileImageData(self.contact!, completion: { (data) in
                    let image = ProfileImage.imageFromData(data)
                    view.profileImageView.image = image
                    self.contactImage = image
                    view.headerCellSpinner.stopAnimating()
                })
            }else {
                let profileImage = ProfileImage.createProfileImage((contact?.firstName)!, last: contact?.lastName)
                view.profileImageView.image = profileImage
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
                if let screenName = contact?.twitterScreenName {
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
    
    
    //MARK: Button Setup
    
    func createAddButton(forAction action:Selector) -> VBFPopFlatButton
    {
        //Here we are going to want to check if the contact has already been added and if they have already been followed on Twitter if that is so, then the button type must be different
        
        
        let button = VBFPopFlatButton(frame: CGRect(x: 0, y: 0, width: kAddButtonWidth, height: kAddButtonWidth), buttonType: .buttonAddType, buttonStyle: .buttonRoundedStyle, animateToInitialState: false)
        
        button?.roundBackgroundColor = UIColor.qnPurpleColor()
        button?.lineThickness = 2.5
        button?.lineRadius = 2
        button?.addTarget(self, action: action, for: .touchUpInside)
        return button!
    }
    
    func constrainButton(_ button:VBFPopFlatButton)
    {
        constrain(button) { button in
            button.trailing   == (button.superview?.trailing)! - kTrailingConstraint
            button.top == (button.superview?.topMargin)! + kTopConstraint
            button.centerY == (button.superview?.centerY)!
        }
    }
    
    func animateToSuccessButton(_ button:VBFPopFlatButton)
    {
        button.roundBackgroundColor = UIColor.qnGreenTealColor()
        button.animate(to: .buttonOkType)
        button.isEnabled = false
    }
    
    func animateToDeniedButton(_ button:VBFPopFlatButton)
    {
        button.roundBackgroundColor = UIColor.qnRedColor()
        button.animate(to: .buttonCloseType)
        button.isEnabled = false
    }
    
    
    //MARK: - Contact Actions
    
    func addContact()
    {
        let contactManager = ContactManager()
        if contactManager.addressBookStatus() == .denied {
            showCantAddContactAlert()
        } else if contactManager.addressBookStatus() == .authorized {
            contactManager.addContact(contact!, image:contactImage)
            showContactAddedToast()
            animateToSuccessButton(addContactButton)
        } else {
            contactManager.promptForAddressBookRequestAccess()
        }
    }
    
    func saveConnection()
    {
        QnUtilitiy.saveConnection(self.contact!) { (error) in
            if error == nil{
                self.sendPushNotification()
                CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("\(self.contact!.firstName) \(self.contact!.lastName) has been saved!", withColor: UIColor.qnOrangeColor()), completionBlock: { () -> Void in
                    
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                
                
            }else {
                CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage((error?.localizedDescription)!, withColor: UIColor.qnOrangeColor()), completionBlock: { () -> Void in
                })
            }
        }
    }
    
    func sendPushNotification()
    {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("username", equalTo: self.contact!.username!)
        print(self.contact!.username!)
        
        // Send push notification to query
        let push = PFPush()
        let data =   ["alert" : "\(User.current()!.firstName) \(User.current()!.lastName) has saved you as a connection!","name" : "\(User.current()!.firstName) \(User.current()!.lastName)", "username":User.current()!.username!, "category" : "cat"]
        push.setData(data)
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?) // Set our Installation query
        push.sendInBackground(block: { (success, error) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    func followContactOnTwitter()
    {
        if User.current()!.twitterScreenName != nil{
            
            QnUtilitiy.followContactOnTwitter(self.contact!, completion: { (json, requestErrorMessage, error) in
                if error == nil {
                    print(json)
                    DispatchQueue.main.async(execute: {
                        if requestErrorMessage != nil {
                            CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage(requestErrorMessage!, withColor: UIColor.qnRedColor()), completionBlock: { () -> Void in
                            })
                            
                            self.animateToDeniedButton(self.addTwitterButton)
                        } else {
                            CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("You are now following \(self.contact!.twitterScreenName!)!", withColor: UIColor.twitterColor())) {}
                            self.animateToSuccessButton(self.addTwitterButton)
                        }
                    })
                }else {
                    print(error!)
                    DispatchQueue.main.async(execute: {
                        self.showInternetError()
                    })
                }

            })
            
        }else {
            showTwitterNotLinkedAlert()
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
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func showInternetError()
    {
        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage(AlertMessages.Internet, withColor: nil), completionBlock: { () -> Void in })
    }
    
    func showContactAddedToast()
    {
         CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("Saved \(contact!.firstName) \(contact!.lastName) to contacts", withColor: UIColor.qnTealColor())){}
    }
    
    func showTwitterNotLinkedAlert()
    {
        
        let twitterAlert = SCLAlertView()
        twitterAlert.addButton("Link With Twitter") { 
            QnUtilitiy.linkTwitterUserInBackground(User.current()!, completion: { (error) in
                if error != nil {
                    print("Error linking with Twitter")
                }else {
                    let twitterSuccess = SCLAlertView()
                    twitterSuccess.showCustom("Success!", subTitle: "Your are now linked with Twitter!", image: UIImage(named: "twitter_circle")!, style: .custom)
                }
            })
        }
        
        twitterAlert.showCustom("Oops!", subTitle: "You must be linked with Twitter to follow user", image: UIImage(named:"twitter_circle")! , style: .custom)
        
    }

    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
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
        default:
            break;
        }
    }
    
    



}
