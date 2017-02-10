//
//  QnUtility.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

import SwiftyJSON
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class QnUtilitiy {
    
    
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
    
    static func setProfileImage(image:UIImage)
    {
        // Get a reference to the storage service using the default Firebase App
        let storageRef = FIRStorage.storage().reference()
        
        // Create a storage reference from our storage service
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child((FIRAuth.auth()?.currentUser?.email)!)
        let profileImageRef = userRef.child("profileImage")
        
        
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        profileImageRef.put(imageData!, metadata: nil) { (metaData, error) in
            guard let metaData = metaData else { print(error!); return }
            
            let downloadURL = metaData.downloadURL()?.absoluteString
        }
    }
    
    static func getProfileImageForUser(user:User, completion:@escaping (UIImage?, Error?) ->Void)
    {
        let storageRef = FIRStorage.storage().reference()
        
        
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child(user.qnectEmail)
        let profileImageRef = userRef.child("profileImage")
        

        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                completion(nil, error! as Error?)
            }
//            let data = NSData(contentsOf: url!)
            let image = UIImage(data: data!)
            
            completion(image, nil)
        }
        
        
//        profileImageRef.downloadURL { (url, error) in
//            if error != nil {
//                completion(nil, error! as Error?)
//            }
//            let data = NSData(contentsOf: url!)
//            let image = UIImage(data: data as! Data)
//            
//            completion(image, nil)
//        }
    }
 
    
    

    
  
    
   
}
