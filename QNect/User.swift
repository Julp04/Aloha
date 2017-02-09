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


class User
{
    var uid:String
    var qnectEmail:String
    
    var username:String!
    var firstName:String!
    var lastName: String!
    
    
    var socialPhone: String?
    var socialEmail: String?
    var twitterScreenName: String?
    
    
    var socialAccounts = [String:String]()
    
  
    
    init(username:String, firstName:String, lastName:String, socialPhone:String?, socialEmail:String?, uid:String, qnectEmail:String)
    {
        self.uid = uid
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.socialPhone = socialPhone
        self.socialEmail = socialEmail
        
        self.qnectEmail = qnectEmail

    }
    
    
    init(authData: FIRUser) {
        self.uid = authData.uid
        self.qnectEmail = authData.email!
        self.username = ""
        self.firstName = ""
        self.lastName = ""
        self.socialPhone = ""
        self.socialEmail = ""

        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let uid = authData.uid
        
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
        
            
            self.username = value?["username"] as? String ?? ""
            self.firstName = value? ["firstName"] as? String ?? ""
            self.lastName = value?["lastName"] as? String ?? ""
            self.socialEmail = value?["socialEmail"] as? String ?? ""
            self.socialPhone = value?["socialPhone"] as? String ?? ""

        })
        
        
    }
    
    static func currentUser(userData:FIRUser, completion: @escaping (User) -> Void)
    {
        
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let uid = userData.uid
        
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            
            let username = value?["username"] as? String ?? ""
            let firstName = value? ["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let socialEmail = value?["socialEmail"] as? String ?? ""
            let socialPhone = value?["socialPhone"] as? String ?? ""
            let uid = userData.uid
            let qnectEmail = userData.email!
            
            let user = User(username: username, firstName: firstName, lastName: lastName, socialPhone: socialPhone, socialEmail: socialEmail, uid: uid, qnectEmail:qnectEmail)
            
            
            
            completion(user)
            
        })
        
        
        
    }
    
  
}




