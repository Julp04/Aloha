//
//  User.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/2016
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit


enum AccountsIdentifiers: String {
    case twitter = "twitter"
    
    static let allIdentifiers = [twitter]
}

class Account {
    var screenName: String
    var token: String
    var tokenSecret: String
    var identifier: AccountsIdentifiers
    
    init(accountDetails: NSDictionary, identifier: AccountsIdentifiers)
    {
        self.screenName = accountDetails["screenName"] as! String
        self.token = accountDetails["token"] as! String
        self.tokenSecret = accountDetails["tokenSecret"] as! String
        self.identifier = identifier
    }
}

class User
{
    var uid: String!
    var email: String!
    var username: String!
    var firstName:String!
    var lastName: String!
    var phone: String?
    var personalEmail: String?
    var location: String?
    var birthdate: String?
    var about: String?
    var isPrivate: Bool
    var followingCount: Int = 0
    var followersCount: Int = 0
    
    var accounts: [Account]?
    var twitterAccount: Account?
    
    var ref: FIRDatabaseReference?
    var key: String?
    
    var profileImage: UIImage?

    
    weak var delegate: ImageDownloaderDelegate?
    
    init?(snapshot:FIRDataSnapshot) {
        
        guard let values = snapshot.value as? NSDictionary else {
            return nil
        }
        
        self.followingCount = values[DatabaseFields.following.rawValue] as! Int
        self.followersCount = values[DatabaseFields.followers.rawValue] as! Int
        
        self.isPrivate = values[DatabaseFields.isPrivate.rawValue] as! Bool
        self.username = values[DatabaseFields.username.rawValue] as! String
        self.firstName = values[DatabaseFields.firstName.rawValue] as! String
        self.lastName = values[DatabaseFields.lastName.rawValue] as! String
        self.personalEmail = values[DatabaseFields.personalEmail.rawValue] as? String
        self.phone = values[DatabaseFields.phone.rawValue] as? String
        self.birthdate = values[DatabaseFields.birthdate.rawValue] as? String
        self.location = values[DatabaseFields.location.rawValue] as? String
        self.about = values[DatabaseFields.about.rawValue] as? String
        
        if let accountsDict = values["accounts"] as? NSDictionary {
            self.accounts = parseAccountsDict(accountsDict: accountsDict)
        }
        
        self.uid = values[DatabaseFields.uid.rawValue] as! String
        self.email = values[DatabaseFields.email.rawValue] as! String
        
        self.key = snapshot.key
        self.ref = snapshot.ref
        
        setAccounts()
    }
    
    private func parseAccountsDict(accountsDict: NSDictionary) -> [Account] {
        var accounts = [Account]()
        
        for identifier in AccountsIdentifiers.allIdentifiers {
            if let details = accountsDict[identifier.rawValue] as? NSDictionary {
                let account = Account(accountDetails: details, identifier: identifier)
                accounts.append(account)
            }
        }
        
        return accounts
    }
    
    private func setAccounts() {
        self.twitterAccount = accounts?.filter { $0.identifier == . twitter}.first
        
        //Add other accounts 
        
    }
    
    
    init(username: String, firstName: String, lastName: String, personalEmail: String?, phone: String?, uid: String, email: String, birthdate: String?, location: String?) {
        
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.personalEmail = personalEmail
        self.phone = phone
        self.uid = uid
        self.email = email
        
        
        self.birthdate = birthdate
        self.location = location
        
        //set to private because when we init user like this it is from scanning a qrcode
        self.isPrivate = false
    }
    
  
}

struct UserInfo
{
    static let testUser = UserInfo()
    
    init() {
        firstName = "Test"
        lastName = "User"
        userName = "testuser"
        email = "test@g.com"
        password = "julian"
    }
    
    var firstName:String? = nil
    var lastName:String? = nil
    var userName:String? = nil
    var email:String? = nil
    var password:String? = nil
}




