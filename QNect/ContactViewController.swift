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
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        
        
        
  
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
        switch section
        {
        case 0:
            
            let view  = tableView.dequeueReusableCell(withIdentifier: "ContactHeaderCell") as! ContactHeaderCell
            view.profileImageView.layer.cornerRadius = (view.profileImageView.frame.height)/2
            view.profileImageView.layer.borderColor = UIColor.white.cgColor
            view.profileImageView.layer.masksToBounds = true
            view.profileImageView.layer.borderWidth = kProfileImageBorderWidth
            
            
            if contact?.profileImage == nil {
                if Reachability.isConnectedToInternet() {
                    QnUtilitiy.getProfileImageForUser(user: contact!, completion: { (profileImage, error) in
                        if error != nil {
                            print(error!)
                        }else {
                            view.profileImageView.image = profileImage
                        }
                    })
                }
            }else {
               view.profileImageView.image = contact?.profileImage
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
            case 0: break
//                if let screenName = contact?.twitterScreenName {
//                    let url = URL(string: "twitter://user?screen_name=\(screenName)")
//                    UIApplication.shared.openURL(url!)
                
//                }
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
        
        button?.roundBackgroundColor = UIColor.qnPurple
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
        button.roundBackgroundColor = UIColor.qnGreenTeal
        button.animate(to: .buttonOkType)
        button.isEnabled = false
    }
    
    func animateToDeniedButton(_ button:VBFPopFlatButton)
    {
        button.roundBackgroundColor = UIColor.qnRed
        button.animate(to: .buttonCloseType)
        button.isEnabled = false
    }
    
    
    //MARK: - Contact Actions
    
    func addContact()
    {
        let contactManager = ContactManager()
        if contactManager.contactStoreStatus() == .denied {
            showCantAddContactAlert()
        } else if contactManager.contactStoreStatus() == .authorized {
            contactManager.addContact(contact!, image: contact?.profileImage, completion: { (success) in
                if success {
                    showContactAddedAlert()
                    animateToSuccessButton(addContactButton)
                }else {
                    RKDropdownAlert.title("Contact could not be added", backgroundColor: UIColor.red, textColor: UIColor.white)
                }
            })
            
        } else {
            contactManager.requestAccessToContacts()
        }
    }
    
    func saveConnection()
    {
        QnUtilitiy.saveContact(contact: contact!)
        
        RKDropdownAlert.title("Woo!", message: "You have added \(contact!.firstName!) \(contact!.lastName!) as a connection!", backgroundColor: UIColor.qnBlue, textColor: UIColor.white)
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
  
    //Todo:Follow contact on twitter implementation
    func followContactOnTwitter()
    {
        let screenName = contact!.accounts["twitter"]!.screenName!
        
        TwitterUtility().followUserWith(screenName: screenName) { (error) in
            if error != nil {
                RKDropdownAlert.title("You are now following \(screenName) on Twitter!", backgroundColor: UIColor.twitter, textColor: UIColor.white)
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
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    
    
    func showContactAddedAlert()
    {
        
        RKDropdownAlert.title("Wooo!", message: "You saved \(contact!.firstName!) \(contact!.lastName!) to your contacts!", backgroundColor: UIColor.qnTeal, textColor: UIColor.white)
    }
    
    func showTwitterNotLinkedAlert()
    {
        
        
        
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
        }
    }
    
    
    //MARK: Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    



}
