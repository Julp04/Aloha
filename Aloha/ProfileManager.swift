//
//  ProfileManager.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/18/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import RKDropdownAlert
import FCAlertView
import ReachabilitySwift

class ProfileManager {
    
    var user: User
    var viewController: UIViewController
    var delegate: ProfileManagerDelegate?
    
    var contactButton: SwitchButton!
    var twitterButton: SwitchButton!
    var facebookButton: SwitchButton!
    var instagramButton: SwitchButton!
    
    var buttons: [SwitchButton]
    let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
    
    init(currentUser: User, viewController: UIViewController) {
        self.user = currentUser
        self.viewController = viewController
        
        buttons = [SwitchButton]()
        
        createButtonsForCurrentUser()
    }
    
    init(user: User, viewController: UIViewController) {
        self.user = user
        self.viewController = viewController
        
        buttons = [SwitchButton]()
        
        createButtonsForUser()
    }
    
    //Setup for current user
   
    private func createButtonsForCurrentUser() {
        twitterButtonCurrentUser()
        contactButtonCurrentUser()
    }
    
    private func twitterButtonCurrentUser() {
        
        twitterButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Add", isOn: false)
        
        twitterButton.onLongPress = {
            if self.twitterButton.isOn  {
            //Opens profile in Twitter application
                if let url = URL(string: "twitter://user?screen_name=\(self.user.twitterAccount!.screenName)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }else {
                        let url = URL(string: "https://twitter.com/\(self.user.twitterAccount!.screenName)")
                        UIApplication.shared.openURL(url!)
                    }
                }
            }
        }
        twitterButton.onClick = {
            if !self.twitterButton.isOn {
                
                guard Reachability.isConnectedToInternet() else {
                    AlertUtility.showConnectionAlert()
                    return
                }
                TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            RKDropdownAlert.title("Oops!", message: error?.localizedDescription, backgroundColor: .qnRed, textColor: .white)
                        }else {
                            self.turnOnTwitterButtonCurrentUser()
                        }
                    }
                })
            }else {
                let alert = FCAlertView()
                alert.addButton("Unlink", withActionBlock: {
                    guard Reachability.isConnectedToInternet() else {
                        AlertUtility.showConnectionAlert()
                        return
                    }
                    
                    TwitterClient.client.unlinkTwitter(completion: { (result) in
                        switch result {
                        case .success(_):
                            self.turnOffTwitterButtonCurrentUser()
                        case .failure(let error):
                            AlertUtility.showAlertWith(error.localizedDescription)
                        }
                    })
                })
                alert.colorScheme = .twitter
                alert.showAlert(inView: self.viewController, withTitle: "Unlink from Twitter", withSubtitle: nil, withCustomImage: #imageLiteral(resourceName: "twitter_off"), withDoneButtonTitle: "Cancel", andButtons: nil)
            }
        }
        
        if (self.user.twitterAccount?.screenName) != nil {
            //User has already linked with Twitter
            self.turnOnTwitterButtonCurrentUser()
        }
        
        
         buttons.append(twitterButton)
    }
    
    private func turnOnTwitterButtonCurrentUser() {
        twitterButton.turnOn()
        self.twitterButton.animationDidStartClosure = {_ in
            QnClient.sharedInstance.currentUser {user in
                self.user = user
                self.twitterButton.shortText = user.twitterAccount!.screenName
            }
            
        }
    }
    
    private func turnOffTwitterButtonCurrentUser() {
        
        DispatchQueue.main.async {
            self.twitterButton.turnOff()
        }
        
        self.twitterButton.animationDidStartClosure = { _ in
            self.twitterButton.shortText = "Add"
        }
        
    }
    
    private func contactButtonCurrentUser() {
        
        switch ContactManager.contactStoreStatus() {
        case .authorized:
            contactButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Contacts \n Linked", isOn: true)
        default:
            contactButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Link Contacts", isOn: false)
            contactButton.onClick =  {
                ContactManager().requestAccessToContacts(completion: { (accessGranted) in
                    if accessGranted {
                        self.turnOnContactButtonCurrentUser()
                    }else {
                        //Show alert that user can turn on access to contacts in settings
                        DispatchQueue.main.async {
                            let alert = FCAlertView()
                            alert.addButton("Dismiss") {}
                            alert.colorScheme = .qnGreen
                            
                            alert.showAlert(inView: self.viewController, withTitle: "Access Denied", withSubtitle: "Go to settings to change access to contacts", withCustomImage: #imageLiteral(resourceName: "contact_logo"), withDoneButtonTitle: "Settings", andButtons: nil)
                            alert.doneActionBlock({
                                let url = URL(string: UIApplicationOpenSettingsURLString)
                                UIApplication.shared.openURL(url!)
                            })
                        }
                        
                    }
                })
            }
        }
        
        buttons.append(contactButton)
    }
    
  
    
   
    
    
    private func turnOnContactButtonCurrentUser() {
        DispatchQueue.main.async {
            self.contactButton.turnOn()
            self.contactButton.isEnabled = false
            self.contactButton.animationDidStartClosure = {_ in
                self.contactButton.shortText = "Contacts Linked"
            }
        }
    }
    
    
    //MARK: Setup for other user
    private func createButtonsForUser() {
        twitterButtonOtherUser()
        contactButtonOtherUser()
    }
    
    private func twitterButtonOtherUser() {
        guard twitterButton == nil else {
            //if twitterButton has already been created then we do not create it again.
            //todo: twitter follow buttton. 
            //We might not need to do this if we update each time and figure out if the current user is currently following the other user
            //Will have to make changes to how twitterButton works
            return
        }
        
        if let screenName = user.twitterAccount?.screenName {
            
            self.twitterButton = SwitchButton(frame: self.buttonFrame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Follow", isOn: false)
            
            twitterButton.onLongPress =  {
                //Opens profile in Twitter application
                if let url = URL(string: "twitter://user?screen_name=\(screenName)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }else {
                        let url = URL(string: "https://twitter.com/\(screenName)")
                        UIApplication.shared.openURL(url!)
                    }
                }
            }

            TwitterClient.client.isFollowing(screenName: screenName, completion: { (isFollowing, error) in
                if isFollowing {
                    self.turnOnTwitterButtonOtherUser()
                }else {
                    //Current user is not following user, present button to allow them to follow
                    self.twitterButton.onClick = {
                        guard Reachability.isConnectedToInternet() else {
                            AlertUtility.showConnectionAlert()
                            return
                        }
                        
                        TwitterClient.client.followUserWith(screenName: screenName, completion: { (error) in
                            if error != nil {
                                RKDropdownAlert.title("Oops!", message: "We could not handle your request", backgroundColor: .gray, textColor: .white)
                            }else {
                                //Follow successful
                                self.turnOnTwitterButtonOtherUser()
                            }
                        })
                    }
                }
            })
            self.buttons.append(self.twitterButton)
        }
    }
    
    private func turnOnTwitterButtonOtherUser() {
        DispatchQueue.main.async {
            self.twitterButton.turnOn()
            self.twitterButton.animationDidStartClosure = { _ in
                self.twitterButton.shortText = "Following"
            }
        }
    }
    
    private func contactButtonOtherUser() {
        
        guard contactButton == nil else {
            return
        }
        
        if ContactManager.contactsAutorized(){
            if ContactManager().contactExists(user: user) {
                contactButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Saved In Contacts", isOn: true)
            }else {
                contactButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Add to contacts", isOn: false)
                contactButton.onClick =  {
                    ContactManager().addContact(self.user, image: self.user.profileImage, completion: { (success) in
                        if success {
                            self.turnOnContactButtonOtherUser()
                        }
                    })
                }
            }
        }else {
            contactButton = SwitchButton(frame: buttonFrame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Add to contacts", isOn: false)
            contactButton.onClick = {
                ContactManager().requestAccessToContacts(completion: { (acessGranted) in
                    if acessGranted {
                        ContactManager().addContact(self.user, image: self.user.profileImage, completion: { (success) in
                            if success {
                                self.turnOnContactButtonOtherUser()
                            }
                        })
                    }else {
                        DispatchQueue.main.async {
                            let alert = FCAlertView()
                            alert.addButton("Settings") {
                                let url = URL(string: UIApplicationOpenSettingsURLString)
                                UIApplication.shared.openURL(url!)
                            }
                            alert.colorScheme = .qnGreen
                            alert.showAlert(inView: self.viewController, withTitle: "Access Denied", withSubtitle: "Go to settings to change access to contacts", withCustomImage: #imageLiteral(resourceName: "contact_logo"), withDoneButtonTitle: "Dismiss", andButtons: nil)
                        }
                    }
                })
            }
        }
        
        buttons.append(contactButton)
    }
    

    private func turnOnContactButtonOtherUser() {
        self.contactButton.turnOn()
        self.contactButton.animationDidStartClosure = { _ in
            self.contactButton.shortText = "Saved In contacts"
            self.contactButton.isEnabled = false
        }
    }
    
    func buttonAtIndexPath(indexPath: IndexPath) -> SwitchButton {
        return buttons[indexPath.row]
    }
    
    func numberOfLinkedAccounts() -> Int {
        return buttons.count
    }
    
    func update(user: User) {
        self.user = user
        createButtonsForUser()
    }
    
}



@objc protocol ProfileManagerDelegate {
   @objc func profileManagerUpdated()
}


