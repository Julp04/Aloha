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

class ProfileManager {
    
    var user: User
    var viewController: UIViewController
    
    var contactButton: SwitchButton!
    var twitterButton: SwitchButton!
    var facebookButton: SwitchButton!
    var instagramButton: SwitchButton!
    
    var buttons = [SwitchButton]()
    
    init(user: User, viewController: UIViewController) {
        self.user = user
        self.viewController = viewController
        
        createButtons()
    }
    
    let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
   
    
    func numberOfLinkedAccounts() -> Int {
        return buttons.count
    }
    
    private func createButtons() {
        createTwitterButton()
        createContactButton()
    }
    
    private func createTwitterButton() {
        
        if let screenName = user.twitterAccount?.screenName {
            twitterButton = SwitchButton(frame: buttonFrame, backgroundColor: .twitter, onTintColor: .white, image: #imageLiteral(resourceName: "twitter_on"), shortText: screenName)
        }else {
            twitterButton = SwitchButton(frame: buttonFrame, backgroundColor: .white, onTintColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Add")
            twitterButton.onClick = {
                TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                    if error != nil {
                      RKDropdownAlert.title("Oops!", message: "poop", backgroundColor: .qnRed, textColor: .white)
                        print(error!)
                    }else {
                        DispatchQueue.main.async {
                            self.turnOnTwitterButton()
                        }
                    }
                })

            }
        }
        buttons.append(twitterButton)
    }
    
    private func turnOnTwitterButton() {
        
        twitterButton.turnOn()
        self.twitterButton.isEnabled = false
        self.twitterButton.animationDidStartClosure = {_ in
            QnClient.sharedInstance.currentUser {user in
                self.twitterButton.shortText = user.twitterAccount!.screenName
            }
            
        }
    }
    
    
    private func createContactButton() {
        
        switch ContactManager.contactStoreStatus() {
        case .authorized:
            contactButton = SwitchButton(frame: buttonFrame, backgroundColor: .qnGreen, onTintColor: .white, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Contacts \n Linked")
            contactButton.isEnabled = false
        default:
            contactButton = SwitchButton(frame: buttonFrame, backgroundColor: .white, onTintColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Link Contacts")
            contactButton.onClick =  {
                ContactManager().requestAccessToContacts(completion: { (accessGranted) in
                    if accessGranted {
                        self.contactButton.turnOn()
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
    
    private func turnOnContactButton() {
        contactButton.turnOn()
        contactButton.isEnabled = false
        contactButton.animationDidStartClosure = {_ in 
            self.contactButton.shortText = "Contacts Linked"
        }
    }
    
    func buttonAtIndexPath(indexPath: IndexPath) -> SwitchButton {
        return buttons[indexPath.row]
    }
    
}
