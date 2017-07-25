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


class AccountManager {
    
    private let frame = CGRect()
    private var viewController: UIViewController
    private var buttons = [SwitchButton]()
    
    init(viewController: UIViewController) {
        
        self.viewController = viewController
        
        let twitterButton = createTwitterButton()
        let contactButton = createContactButton()
        let snapchatButton = createSnapchatButton()
        
        buttons = [twitterButton, contactButton]
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
    
    private func createContactButton() -> SwitchButton {
        
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
    private func createTwitterButton() -> SwitchButton {
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
    private func createSnapchatButton() -> SwitchButton {
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


