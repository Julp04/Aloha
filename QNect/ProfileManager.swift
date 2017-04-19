//
//  ProfileManager.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/18/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class ProfileManager {
    
    var user: User
    init(user: User) {
        self.user = user
    }
    
   
    
    private func numberOfLinkedAccounts() -> Int {
        return user.accounts?.count ?? 0
    }
    
    func twitterButton() -> SwitchButton {
         let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
        
        var twitterButton: SwitchButton
        
        if let screenName = user.twitterAccount?.screenName {
            twitterButton = SwitchButton(frame: buttonFrame, backgroundColor: .twitter, onTintColor: .white, image: #imageLiteral(resourceName: "twitter_on"), shortText: screenName)
        }else {
            twitterButton = SwitchButton(frame: buttonFrame, backgroundColor: .white, onTintColor: .twitter, image: #imageLiteral(resourceName: "twitter_on"), shortText: "Add")
        }
        
        return twitterButton
        
    }
}
