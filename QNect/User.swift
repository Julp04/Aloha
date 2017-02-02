//
//  User.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/2016
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import Parse

class User:PFUser
{
    @NSManaged var firstName:String
    @NSManaged var lastName: String
    
    
    @NSManaged var socialPhone: String?
    @NSManaged var socialEmail: String?
    @NSManaged var twitterScreenName: String?
    @NSManaged var profileImage:PFFile?
    @NSManaged var spotifyName:String?
    
    var socialAccounts = [String:String]()
    
    
    convenience init(username:String, firstName:String, lastName:String, socialPhone:String?, socialEmail:String?, twitterScreenName:String?)
    {
        self.init()
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.socialEmail = socialEmail
        self.socialPhone = socialPhone
        self.twitterScreenName = twitterScreenName
    }
    
  
}




