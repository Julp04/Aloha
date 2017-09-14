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

protocol AccountsProtocol {
    var twitterButton: SwitchButton? {get set}
    var contactButton: SwitchButton? {get set}
    var snapchatButton: SwitchButton? {get set}
    
    
    func createContactButton()
    func createTwitterButton()
    func createSnapchatButton()
}

class AccountManager: AccountsProtocol {
    
    internal var frame: CGRect
    internal var viewController: UIViewController
    internal var buttons = [SwitchButton]()
    
    var twitterButton: SwitchButton?
    var contactButton: SwitchButton?
    var snapchatButton: SwitchButton?
    
    init(viewController: UIViewController, frame: CGRect = CGRect()) {
        self.frame = frame
        self.viewController = viewController
        
        assignButtons()
    }
    
    internal func assignButtons() {
        createContactButton()
        createTwitterButton()
        createSnapchatButton()
        
        buttons.removeAll()
        let tmpButtons = [twitterButton, contactButton, snapchatButton]
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
    
    func createContactButton() {
        
        contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), title: "Add Contacts", description: "Allow Aloha to access your contacts to easily import new connections")
        let whiteSnow = Snowflake(view: contactButton!, particles: [#imageLiteral(resourceName: "message_particle"), #imageLiteral(resourceName: "phone_particle")], color: .white)
        let greenSnow = Snowflake(view: contactButton!, particles: [#imageLiteral(resourceName: "message_particle"), #imageLiteral(resourceName: "phone_particle")], color: .qnGreen)
        contactButton?.layer.addSublayer(greenSnow)
        contactButton?.layer.addSublayer(whiteSnow)
        greenSnow.start()
        

        switch ContactManager.contactStoreStatus() {
        case .authorized:
            contactButton?.turnOn(animated: false)
            contactButton?.buttonTitle = "Contacts Linked"
            greenSnow.stop()
            whiteSnow.start()
        default:
            break
        }
        contactButton?.onClick = {
            ContactManager().requestAccessToContacts { accessGranted in
                if accessGranted {
                    DispatchQueue.main.async {
                        self.contactButton?.turnOn(animated: true)
                        self.contactButton?.buttonTitle = "Contacts Linked"
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
    }
    func createTwitterButton() {
        twitterButton = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), title: "Add Twitter Account", description: "Link your Twitter account to instantly follow friends when you connect")
        
        let blueFlake = Snowflake(view: twitterButton!, particles: [#imageLiteral(resourceName: "twitter_on")], color: .twitter)
        let whiteFlake = Snowflake(view: twitterButton!, particles: [#imageLiteral(resourceName: "twitter_on")], color: .white)
        twitterButton?.layer.addSublayer(whiteFlake)
        twitterButton?.layer.addSublayer(blueFlake)
        blueFlake.start()
        
        twitterButton?.onClick = {
            TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                if let error = error {
                    RKDropdownAlert.title("Oops!", message: error.localizedDescription, backgroundColor: .qnRed, textColor: .white)
                }else {
                    DispatchQueue.main.async {
                        self.twitterButton?.turnOn()
                        self.twitterButton?.isEnabled = false
                        
                        QnClient.sharedInstance.currentUser(completion: { (user) in
                            self.twitterButton?.buttonTitle = user?.twitterAccount?.screenName
                        })
                        self.twitterButton?.buttonDescription = "You are linked with Twitter"
                        blueFlake.stop()
                        whiteFlake.start()
                    }
                }
            })
        }
    }
    
    func createSnapchatButton() {
        
        let snapColor = #colorLiteral(red: 0.9529411793, green: 0.9141744421, blue: 0.3056259536, alpha: 1)
        snapchatButton = SwitchButton(frame: frame, offColor: .white, onColor:snapColor , image: #imageLiteral(resourceName: "snap"), title: "Add Snapchat Account", description: "Link your Snapchat to account to easily follow new connections on Snapchat")
        
        let whiteFlake  = Snowflake(view: snapchatButton!, particles: [#imageLiteral(resourceName: "snap"): .white])
        let yellowFlake = Snowflake(view: snapchatButton!, particles: [#imageLiteral(resourceName: "snap"): snapColor])
        
        snapchatButton?.layer.addSublayer(whiteFlake)
        snapchatButton?.layer.addSublayer(yellowFlake)
        yellowFlake.start()
        
        snapchatButton?.onClick = {
            var hitAdd = 0
            var snapchatUsername = ""
            let alert = FCAlertView()
            
            alert.addTextField(withPlaceholder: "Username") { (string) in
                snapchatUsername  = string!
                
                if hitAdd == 1 {
                    if snapchatUsername != "" {
                        //Add snapchat username
                        self.snapchatButton?.turnOn()
                        self.snapchatButton?.isEnabled = false
                        self.snapchatButton?.buttonTitle = snapchatUsername.lowercased()
                        
                        QnClient.sharedInstance.addSnapchat(screenName: snapchatUsername.lowercased())
                        
                        self.snapchatButton?.buttonDescription = "You are linked with Snapchat"
                        yellowFlake.stop()
                        whiteFlake.start()
                    }else {
                        RKDropdownAlert.title("Username cannot be blank", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                    }
                }
            }
            alert.addButton("Cancel", withActionBlock: {
                hitAdd = 0
            })
            alert.doneActionBlock {
                hitAdd = 1
            }
            alert.colorScheme = snapColor
            alert.showAlert(inView: self.viewController, withTitle: "Snapchat", withSubtitle: "Enter your Snapchat username!", withCustomImage: #imageLiteral(resourceName: "snap"), withDoneButtonTitle: "Add", andButtons: nil)

        }
    }

}

class CurrentUserAccountManager: AccountManager {
    internal var user: User
    internal var client = QnClient()
    
    
    init(user: User, viewController: UIViewController) {
        self.user = user
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
        super.init(viewController: viewController, frame: buttonFrame)
      
    }
    
    override func createTwitterButton() {

        if twitterButton == nil {
            twitterButton = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Add", isOn: false)
        }
        
        func turnOn(animated: Bool = true) {
            twitterButton?.turnOn(animated: animated)
            self.client.currentUser {user in
                self.user = user!
                self.twitterButton?.shortText = user!.twitterAccount?.screenName
            }
        }
        
        func turnOff() {
            twitterButton?.turnOff()
            twitterButton?.shortText = "Add"
        }
        
        twitterButton?.onLongPress = {
            if self.twitterButton!.isOn  {
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
        twitterButton?.onClick = {
            if !self.twitterButton!.isOn {
                guard Reachability.isConnectedToInternet() else {
                    AlertUtility.showConnectionAlert()
                    return
                }
                TwitterClient.client.linkTwitterIn(viewController: self.viewController, completion: { (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            RKDropdownAlert.title("Oops!", message: error?.localizedDescription, backgroundColor: .qnRed, textColor: .white)
                        }else {
                            DispatchQueue.main.async {
                                turnOn()
                            }
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
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                turnOff()
                            case .failure(let error):
                                AlertUtility.showAlertWith(error.localizedDescription)
                            }
                        }
                    })
                })
                alert.colorScheme = .twitter
                alert.showAlert(inView: self.viewController, withTitle: "Unlink from Twitter", withSubtitle: nil, withCustomImage: #imageLiteral(resourceName: "twitter_off"), withDoneButtonTitle: "Cancel", andButtons: nil)
            }
        }
        
        if (self.user.twitterAccount?.screenName) != nil {
            //User has already linked with Twitter
            DispatchQueue.main.async {
                turnOn(animated: true)
            }
        }
        
    }
    override func createContactButton(){
        if contactButton == nil {
            contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Link Contacts", isOn: false)
        }
        
        func turnOn(animated: Bool = true) {
            contactButton?.turnOn(animated: animated)
            contactButton?.shortText = "Contacts Linked"
        }
        
        switch ContactManager.contactStoreStatus() {
        case .authorized:
            DispatchQueue.main.async {
                turnOn(animated: false)
            }
        default:
            contactButton?.onClick =  {
                ContactManager().requestAccessToContacts(completion: { (accessGranted) in
                    if accessGranted {
                        DispatchQueue.main.async {
                            turnOn()
                        }
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
    }
    override func createSnapchatButton() {
        if snapchatButton == nil {
            snapchatButton =  SwitchButton(frame: frame, offColor: .white, onColor: .snapchat, image: #imageLiteral(resourceName: "snap"), shortText: "Add", isOn: false)
        }
        
        func turnOn(animated: Bool = true) {
            snapchatButton?.turnOn(animated: animated)
            self.client.currentUser {user in
                self.user = user!
                self.snapchatButton?.shortText = user!.snapchatAccount?.screenName
            }
        }
        
        func turnOff() {
            snapchatButton?.turnOff()
            snapchatButton?.shortText = "Add"
        }
        
        snapchatButton?.onLongPress =  {
            if twitterButton?.isOn {
                let url = URL(string: "https://snapchat.com/add/\(self.user.snapchatAccount!.screenName)")!
                UIApplication.shared.openURL(url)
            }
        }
        
        snapchatButton?.onClick = {
            if !self.snapchatButton!.isOn {
                
                var hitAdd = 0
                var snapchatUsername = ""
                let alert = FCAlertView()
                
                alert.addTextField(withPlaceholder: "Username") { (string) in
                    snapchatUsername  = string!
                    
                    if hitAdd == 1 {
                        if snapchatUsername != "" {
                            //Add snapchat username
                            
                            QnClient.sharedInstance.addSnapchat(screenName: snapchatUsername.lowercased())
                            turnOn()
                        }else {
                            RKDropdownAlert.title("Username cannot be blank", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
                        }
                    }
                }
                alert.addButton("Cancel", withActionBlock: {
                    hitAdd = 0
                })
                alert.doneActionBlock {
                    hitAdd = 1
                }
                alert.colorScheme = .snapchat
                alert.showAlert(inView: self.viewController, withTitle: "Snapchat", withSubtitle: "Enter your Snapchat username!", withCustomImage: #imageLiteral(resourceName: "snap"), withDoneButtonTitle: "Add", andButtons: nil)
                
            }else {
                let alert = FCAlertView()
                alert.addButton("Unlink", withActionBlock: {
                    QnClient.sharedInstance.removeSnapchat()
                    turnOff()
                })
                alert.colorScheme = .snapchat
                alert.showAlert(inView: self.viewController, withTitle: "Unlink from Snapchat", withSubtitle: nil, withCustomImage: #imageLiteral(resourceName: "snap"), withDoneButtonTitle: "Cancel", andButtons: nil)
            }
        }
        
        if self.user.snapchatAccount?.screenName != nil {
            DispatchQueue.main.async {
                turnOn(animated: true)
            }
        }
    }
    
    internal func update(user: User) {
        self.user = user
        self.assignButtons()
    }
}

class OtherUserAccountManager: CurrentUserAccountManager {
    
    var delegate: AccountManagerDelegate?
    
    override func createTwitterButton(){
        if let screenName = user.twitterAccount?.screenName {
            if twitterButton == nil {
                twitterButton = SwitchButton(frame: frame, offColor: .white, onColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Follow", isOn: false)
            }
            
            func turnOn(animated: Bool = true) {
                twitterButton?.turnOn(animated: animated)
                twitterButton?.shortText = "Following"
            }
            
            func turnOff(animated: Bool = true) {
                twitterButton?.turnOff()
                twitterButton?.shortText = "Follow"
            }
            
            twitterButton?.onLongPress =  {
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
            
            
            self.twitterButton?.onClick =  {
                if self.twitterButton!.isOn {
                    let alert = FCAlertView()
                    alert.addButton("Unfollow") {
                        TwitterClient.client.unFollowUserWith(screenName: screenName, completion: { (error) in
                            if let error = error {
                                print(error)
                            }else {
                                turnOff()
                            }
                        })
                    }
                    alert.colorScheme = .twitter
                    alert.showAlert(inView: self.viewController, withTitle: "Unfollow \(screenName)", withSubtitle: "Do you want to unfollow \(screenName) on Twitter", withCustomImage: #imageLiteral(resourceName: "twitter_off"), withDoneButtonTitle: "Dismiss", andButtons: nil)
                }else {
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
                            DispatchQueue.main.async {
                                alert.colorScheme = .twitter
                                alert.showAlert(inView: self.viewController, withTitle: "Not linked with Twitter!", withSubtitle: "You need to link with Twitter to follow this user!", withCustomImage: #imageLiteral(resourceName: "twitter_off"), withDoneButtonTitle: "Cancel", andButtons: nil)
                            }
                            return
                        }
                    })
                    
                    TwitterClient.client.followUserWith(screenName: screenName, completion: { (error) in
                        if error != nil {
                            RKDropdownAlert.title("Oops!", message: "We could not handle your request", backgroundColor: .gray, textColor: .white)
                        }else {
                            //Follow successful
                            DispatchQueue.main.async {
                                turnOn()
                            }
                        }
                    })
                }
            }
            
            TwitterClient.client.isFollowing(screenName: screenName, completion: { (isFollowing, error) in
                if isFollowing {
                    DispatchQueue.main.async {
                        turnOn()
                    }
                }
            })
        }
    }
    override func createContactButton(){
        func turnOn() {
            contactButton?.turnOn()
            contactButton?.animationDidStartClosure = { _ in
                self.contactButton?.shortText = "Saved In contacts"
                self.contactButton?.isEnabled = false
            }
        }

        if contactButton == nil {
            contactButton = SwitchButton(frame: frame, offColor: .white, onColor: .qnGreen, image: #imageLiteral(resourceName: "contact_logo"), shortText: "Add to contacts", isOn: false)
        }
       
        if ContactManager.contactsAutorized(){
            if ContactManager().contactExists(user: user) {
                turnOn()
            }else {
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
    }
    override func createSnapchatButton() {
        
    }
    
}

@objc protocol AccountManagerDelegate {
    @objc func accountManagerUpdated()
}



