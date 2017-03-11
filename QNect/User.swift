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





class Account {
    
    
    var key: String
    var ref: FIRDatabaseReference
    var screenName:String?
    var token:String
    var refreshToken:String
    
    init(snapshot:FIRDataSnapshot)
    {
        let values = snapshot.value as! NSDictionary
        
        self.key = snapshot.key
        self.ref = snapshot.ref
        self.screenName = values["screenName"] as? String
        self.token = values["token"] as! String
        self.refreshToken = values["refreshToken"] as! String
    }
    
    
}

class TwitterAccount: Account {
    
    
}


class User
{
    var uid:String!
    var email:String!
    var username:String!
    var firstName:String!
    var lastName: String!
    var socialPhone: String?
    var socialEmail: String?
    var twitterScreenName:String?
    var ref:FIRDatabaseReference?
    var key: String?

    var profileImage:UIImage?
    
    weak var delegate:ImageDownloaderDelegate?
    
    init(snapshot:FIRDataSnapshot) {
        
        let values = snapshot.value as! NSDictionary
        
        self.username = values["username"] as! String
        self.firstName = values["firstName"] as! String
        self.lastName = values["lastName"] as! String
        self.socialEmail = values["socialEmail"] as? String
        self.socialPhone = values["socialPhone"] as? String
        self.twitterScreenName = values["twitterScreenName"] as? String
        self.uid = values["uid"] as! String
        self.email = values["email"] as! String
        
        self.key = snapshot.key
        self.ref = snapshot.ref
        
    }
    
    
    init(username:String, firstName:String, lastName:String, socialEmail:String?, socialPhone:String?, uid:String, email:String, twitterScreenName:String?) {
        
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.socialEmail = socialEmail
        self.socialPhone = socialPhone
        self.uid = uid
        self.email = email
        self.twitterScreenName = twitterScreenName
        
    }
    
    init(userInfo:UserInfo) {
        self.username = userInfo.userName
        self.firstName = userInfo.firstName
        self.lastName = userInfo.lastName
        self.email = userInfo.email
    }
    
  
}




