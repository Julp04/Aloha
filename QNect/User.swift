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
    var profileImage:UIImage?
    
    weak var delegate:ImageDownloaderDelegate?
    
  
    
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
        let uidRef = usersRef.child(uid)
        let userInfoRef = uidRef.child("userInfo")
        
        
        userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
        
            
            self.username = value?["username"] as? String ?? ""
            self.firstName = value? ["firstName"] as? String ?? ""
            self.lastName = value?["lastName"] as? String ?? ""
            self.socialEmail = value?["socialEmail"] as? String ?? ""
            self.socialPhone = value?["socialPhone"] as? String ?? ""

        })
    }
    
    
    init(snapshot:FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.firstName = snapshotValue["firstName"] as! String
        self.lastName = snapshotValue["lastName"] as! String
        self.socialEmail = snapshotValue["socialEmail"] as? String
        self.socialPhone = snapshotValue["socialPhone"] as? String
        self.username = snapshotValue["username"] as! String
        self.uid = snapshotValue["uid"] as! String
        self.qnectEmail = snapshotValue["qnectEmail"] as! String
        
        
        
        
        let storageRef = FIRStorage.storage().reference()
        
        
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child(qnectEmail).child("profileImage")
        
        
        userRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            
            if error != nil {
                print(error!)
            }else {
                let image = UIImage(data: data!)
                self.profileImage = image
                self.delegate?.imageDownloaded(image: image!)
            }
        }

        
    }

    
    static func currentUser(userData:FIRUser, completion: @escaping (User) -> Void)
    {
        
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        let uidRef = usersRef.child(userData.uid)
        let userInfoRef = uidRef.child("userInfo")
        
       userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
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




