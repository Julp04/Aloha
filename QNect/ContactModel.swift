//
//  ContactModel.swift
//  QNect
//
//  Created by Julian Panucci on 11/13/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

class ContactModel
{
    var contact:User
    
    init(contact:User)
    {
        self.contact = contact
    }
    

    
    func numberOfSocialAccounts() -> Int
    {
        return contact.accounts.count
    }
    
    func socialAccountAtIndex(_ index:Int) -> String
    {
        let accounts = [Account] (contact.accounts.values)
        let screenName = accounts[index].screenName!
        
        return screenName
        
    }
    
    func socialAccountTypeAtIndex(_ index:Int) -> String
    {
        let keys = [String](contact.accounts.keys)
        return keys[index]
    }
    
    func imageForSocialAccountAtIndex(_ index:Int) -> UIImage?
    {
        let services = [String](contact.accounts.keys)
        let service = services[index]
        
        switch service
        {
        case AccountsKey.Twitter:
            return UIImage(named: "twitter_circle")!
        case AccountsKey.Spotify:
            return UIImage(named: "spotify_circle")!
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
