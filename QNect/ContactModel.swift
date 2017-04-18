//
//  ContactModel.swift
//  QNect
//
//  Created by Julian Panucci on 11/13/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import UIKit

class ContactModel
{
    var contact:User
    var socialAccounts = [String:String]()
    
    init(contact:User)
    {
        self.contact = contact
        
        if let twitterScreenName = contact.twitterAccount?.screenName {
            socialAccounts["twitter"] = twitterScreenName
        }
    }
    

    
    func numberOfSocialAccounts() -> Int
    {
        return socialAccounts.count
    }
    
    func socialAccountAtIndex(_ index:Int) -> String
    {
        
        let accounts = [String] (socialAccounts.values)
        let screenName = accounts[index]
        
        return screenName
        
    }
    
    func socialAccountTypeAtIndex(_ index:Int) -> String
    {
        let keys = [String] (socialAccounts.keys)
        return keys[index]
    }
    
    func imageForSocialAccountAtIndex(_ index:Int) -> UIImage?
    {
        
        
        let services = [String] (socialAccounts.keys)
        let service = services[index]
        
        switch service
        {
        case AccountsKey.Twitter:
            return UIImage(named: "twitter_circle")!
        default:
            return nil
        }
    }
    
    func phoneNumberForContact() -> String
    {
        if contact.socialPhone != "" {
            let mutableString = NSMutableString(string: contact.socialPhone!)
            mutableString.insert("(", at: 0)
            mutableString.insert(")-", at: 4)
            mutableString.insert("-", at: 9)
            return mutableString as String
        }else {
            return ""
        }
    }
    
    func socialEmailForContact() -> String
    {
        return contact.socialEmail!
    }
    
    func nameForContact() -> String
    {
        return "\(contact.firstName!) \(contact.lastName!)"
    }
    
}

struct AccountsKey
{
    static let Twitter = "twitter"
    static let Spotify = "spotify"
}
