//
//  QnUtility.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

import ParseTwitterUtils
import SwiftyJSON
import FirebaseAuth
import FirebaseDatabase

class QnUtilitiy {
    
    static let sharedInstance = QnUtilitiy()
    
    
    var ref : FIRDatabaseReference!
    var usersRef : FIRDatabaseReference!
    var currentUserRef:FIRUser!
    var currentUser:User
    
    init() {
        
        currentUserRef = FIRAuth.auth()?.currentUser
        
        currentUser = User(authData: currentUserRef)
    }
    
    
    static func setUserInfoFor(user:FIRUser,username:String, firstName:String, lastName:String, socialEmail:String?, socialPhone:String?)
    {
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        usersRef.child(user.uid).setValue(["username":username, "firstName":firstName, "lastName":lastName, "socialEmail":socialEmail,"socialPhone":socialPhone, "qnectEmail":user.email])
    }
    
    
    static func updateUserInfo(firstName:String, lastName:String, socialEmail:String?, socialPhone:String?)
    {
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let currentUser = FIRAuth.auth()?.currentUser!
        
        usersRef.child((currentUser?.uid)!).updateChildValues(["firstName":firstName, "lastName":lastName, "socialPhone":socialPhone!, "socialEmail":socialEmail!])
    }
 
    
    

    
  
    
   
}
