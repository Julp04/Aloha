//
//  AccountManager.swift
//  Aloha
//
//  Created by Panucci, Julian R on 7/23/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import UIKit
import FCAlertView
import RKDropdownAlert
import ReachabilitySwift



class AccountManager {
    
    internal var frame = CGRect()
    internal var viewController: UIViewController
    internal var buttons = [SwitchButton]()
    
    
    init(viewController: UIViewController) {
        
        self.viewController = viewController
        assignButtons()
    }
    
    internal func assignButtons() {
        buttons.removeAll()
        let tmpButtons = [createTwitterButton(), createContactButton()]
        for button in tmpButtons {
            if let button = button {
                buttons.append(button)
            }
        }
    }
  
    public func numberOfAccounts() -> Int {
        return buttons.count
    }
    
    public func buttonAt(index: Int, frame: CGRect) -> SwitchButton {
        let button = buttons[index]
        button.frame = frame
        
        if let layers = button.layer.sublayers {
            for layer in layers {
                if layer is Snowflake {
                    layer.frame = button.frame
                }
            }
        }
        return button
    }
    
    public func buttonAt(index: Int) -> SwitchButton {
        let button = buttons[index]
        return button
    }
    
    func createContactButton() -> SwitchButton? {
        
        let button = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), title: "Add Contacts", description: "Allow Aloha to access your contacts to easily import new connections")
        let whiteSnow = Snowflake(view: button, particles: [#imageLiteral(resourceName: "message_particle"), #imageLiteral(resourceName: "phone_particle")], color: .white)
        let greenSnow = Snowflake(view: button, particles: [#imageLiteral(resourceName: "message_particle"), #imageLiteral(resourceName: "phone_particle")], color: .qnGreen)
        button.layer.addSublayer(greenSnow)
        button.layer.addSublayer(whiteSnow)
        greenSnow.start()
        

        switch ContactManager.contactStoreStatus() {
        case .authorized:
            button.turnOn(animated: false)
            button.buttonTitle = "Contacts Linked"
            greenSnow.stop()
            whiteSnow.start()
        default:
            break
        }
        button.onClick = {
            ContactManager().requestAccessToContacts { accessGranted in
                if accessGranted {
                    DispatchQueue.main.async {
                        button.turnOn(animated: true)
                        button.buttonTitle = "Contacts Linked"
                        whiteSnow.start()
                        greenSnow.stop()
                    }
                }else {
                    //Show alert that user can turn on access to contacts in settings
                    DispatchQueue.main.async {
                        let alert = FCAlertView()
                        alert.addButton("Dismiss") {
                            alert.dismiss()
                        }
                        alert.colorScheme = .qnGreen
                        alert.showAlert(inView: self.viewController, withTitle: "Access Denied", withSubtitle: "Go to settings to change access to contacts", withCustomImage: #imageLiteral(resourceName: "contact_logo"), withDoneButtonTitle: "Settings", andButtons: nil)
                        alert.doneBlock = {
                            let url = URL(string: UIApplicationOpenSettingsURLString)
                            UIApplication.shared.openURL(url!)
                        }
                    }
                }
            }
        }
        return button
    }
    func createTwitterButton() -> SwitchButton? {
        let button = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), title: "Add Twitter Account", description: "Link your Twitter account to instantly follow friends when you connect")
        
        let blueFlake = Snowflake(view: button, particles: [#imageLiteral(resourceName: "twitter_on")], color: .twitter)
        let whiteFlake = Snowflake(view: button, particles: [#imageLiteral(resourceName: "twitter_on")], color: .white)
        button.layer.addSublayer(whiteFlake)
        button.layer.addSublayer(blueFlake)
        blueFlake.start()
        
        button.onClick = {
            TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                if let error = error {
                    RKDropdownAlert.title("Oops!", message: error.localizedDescription, backgroundColor: .qnRed, textColor: .white)
                }else {
                    button.turnOn()
                    button.isEnabled = false
                    button.animationDidStartClosure = {_ in
                        QnClient.sharedInstance.currentUser {user in
                            button.buttonTitle = user!.twitterAccount!.screenName
                        }
                        button.buttonDescription = "You are linked with Twitter"
                        blueFlake.stop()
                        whiteFlake.start()
                    }
                }
            })
        }
        return button
    }
    func createSnapchatButton() -> SwitchButton? {
        let button = SwitchButton(frame: frame, offColor: .white, onColor: #colorLiteral(red: 1, green: 0.8761399504, blue: 0, alpha: 1), image: #imageLiteral(resourceName: "snap"), title: "Add Snapchat", description: "Add snapchat username to quickly find friends on snapchat", isOn: false)
        let whiteFlake = Snowflake(view: button, particles: [#imageLiteral(resourceName: "snap")], color: .white)
        let yellowFlake = Snowflake(view: button, particles: [#imageLiteral(resourceName: "snap")], color: #colorLiteral(red: 1, green: 0.8761399504, blue: 0, alpha: 1))
        button.layer.addSublayer(whiteFlake)
        whiteFlake.start()
        
        button.onClick =  {
            button.switchState()
        }
        
        return button
    }
}

class CurrentUserAccountManager: AccountManager {
    internal var user: User
    internal var client = QnClient()
    
    
    init(user: User, viewController: UIViewController) {
        self.user = user
        super.init(viewController: viewController)
        frame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
    }
    
    override func createTwitterButton() -> SwitchButton? {
        let button = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Add", isOn: false)
        
        func turnOn(animated: Bool = true) {
            button.turnOn(animated: animated)
            self.client.currentUser {user in
                self.user = user!
                button.shortText = user!.twitterAccount?.screenName
            }
        }
        
        func turnOff() {
            button.turnOff()
            button.shortText = "Add"
        }
        
        button.onLongPress = {
            if button.isOn  {
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
        button.onClick = {
            if !button.isOn {
                guard Reachability.isConnectedToInternet() else {
                    AlertUtility.showConnectionAlert()
                    return
                }
                TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            RKDropdownAlert.title("Oops!", message: error?.localizedDescription, backgroundColor: .qnRed, textColor: .white)
                        }else {
                            turnOn()
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
                            turnOff()
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
            turnOn(animated: false)
        }
        
        return button
    }
    override func createContactButton() -> SwitchButton? {
        
        let button = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Link Contacts", isOn: false)
        
        func turnOn(animated: Bool = true) {
            button.turnOn(animated: animated)
            button.shortText = "Contacts Linked"
        }
        
        switch ContactManager.contactStoreStatus() {
        case .authorized:
            DispatchQueue.main.async {
                turnOn(animated: false)
            }
        default:
            button.onClick =  {
                ContactManager().requestAccessToContacts(completion: { (accessGranted) in
                    if accessGranted {
                        turnOn()
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
        return button
    }
    
    internal func update(user: User) {
        self.user = user
        self.assignButtons()
    }
}

class OtherUserAccountManager: CurrentUserAccountManager {
    
    var delegate: AccountManagerDelegate?
    
    override func createTwitterButton() -> SwitchButton? {
        if let screenName = user.twitterAccount?.screenName {
            let button = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Follow", isOn: false)
            
            func turnOn() {
                //todo: Needs to be on main queue
                button.turnOn()
                button.animationDidStartClosure = { _ in
                    button.shortText = "Following"
                }
            }
            
            button.onLongPress =  {
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
                    turnOn()
                }else {
                    //Current user is not following user, present button to allow them to follow
                    button.onClick = {
                        guard Reachability.isConnectedToInternet() else {
                            AlertUtility.showConnectionAlert()
                            return
                        }
                        
                        self.client.currentUser(completion: { (user) in
                            if user!.twitterAccount == nil {
                                let alert = FCAlertView()
                                alert.addButton("Link", withActionBlock: {
                                    guard Reachability.isConnectedToInternet() else {
                                        AlertUtility.showConnectionAlert()
                                        return
                                    }
                                    TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                                        if error != nil {
                                            print(error!)
                                        }
                                    })
                                })
                                alert.colorScheme = .twitter
                                alert.showAlert(inView: self.viewController, withTitle: "Not linked with Twitter!", withSubtitle: "You need to link with Twitter to follow this user!", withCustomImage: #imageLiteral(resourceName: "twitter_off"), withDoneButtonTitle: "Cancel", andButtons: nil)
                                return
                            }
                        })
                        
                        TwitterClient.client.followUserWith(screenName: screenName, completion: { (error) in
                            if error != nil {
                                RKDropdownAlert.title("Oops!", message: "We could not handle your request", backgroundColor: .gray, textColor: .white)
                            }else {
                                //Follow successful
                                turnOn()
                            }
                        })
                    }
                }
            })
            
            return button
        }else {
            return nil
        }
        
    }
    override func createContactButton() -> SwitchButton? {
        var contactButton: SwitchButton?
        
        func turnOn() {
            contactButton?.turnOn()
            contactButton?.animationDidStartClosure = { _ in
                contactButton?.shortText = "Saved In contacts"
                contactButton?.isEnabled = false
            }
        }
        
        
        if ContactManager.contactsAutorized(){
            if ContactManager().contactExists(user: user) {
                contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Saved In Contacts", isOn: true)
            }else {
                contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Add to contacts", isOn: false)
                contactButton?.onClick =  {
                    ContactManager().addContact(self.user, image: self.user.profileImage, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                turnOn()
                            }
                        }
                    })
                }
            }
        }else {
            contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Add to contacts", isOn: false)
            contactButton?.onClick = {
                ContactManager().requestAccessToContacts(completion: { (acessGranted) in
                    if acessGranted {
                        ContactManager().addContact(self.user, image: self.user.profileImage, completion: { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    turnOn()
                                }
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
        return contactButton
    }
    
}

@objc protocol AccountManagerDelegate {
    @objc func accountManagerUpdated()
}



