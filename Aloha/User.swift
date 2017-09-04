//
//  User.swift
//  Aloha
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
    case snapchat = "snapchat"
    
    static let allIdentifiers = [twitter, snapchat]
}

class Account {
    var screenName: String
    var token: String?
    var tokenSecret: String?
    var identifier: AccountsIdentifiers
    
    init(accountDetails: NSDictionary, identifier: AccountsIdentifiers)
    {
        self.screenName = accountDetails["screenName"] as! String
        self.identifier = identifier
        
        if let token = accountDetails["token"] as? String, let tokenSecret = accountDetails["tokenSecret"] as? String {
            self.token = token
            self.tokenSecret = tokenSecret
        }
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
    
    var accounts: [Account]?
    var twitterAccount: Account?
    
    var ref: FIRDatabaseReference?
    var key: String?
    
    var profileImage: UIImage?
    var profileImageURL: String?
    
    init?(snapshot:FIRDataSnapshot) {
        
        guard let values = snapshot.value as? NSDictionary else {
            return nil
        }
        
        self.isPrivate = values[DatabaseFields.isPrivate.rawValue] as? Bool ?? false
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
        if let url = values["photoURL"] as? String {
            self.profileImageURL = url
        }
        
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
    
    func fullName() -> String {
        return "\(firstName!) \(lastName!)"
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




