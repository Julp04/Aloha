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
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("profileImage")
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            
            
            
            // Get a reference to the storage service using the default Firebase App
            let storageRef = FIRStorage.storage().reference()
            
            // Create a storage reference from our storage service
            let userStorageRef = storageRef.child("users")
            let userRef = userStorageRef.child((FIRAuth.auth()?.currentUser?.email)!)
            let profileImageRef = userRef.child("profileImage")
            
            
            // Create a reference to the file you want to uplo
            
            // Upload the file to the path "images/rivers.jpg"
            _ = profileImageRef.putFile(fileURL, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    _ = metadata!.downloadURL()
                }
            }
        } catch { }
    }
    
    
    static func getProfileImageForUser(user:User, completion:@escaping (UIImage?, Error?) ->Void)
    {
        let storageRef = FIRStorage.storage().reference()
        
        
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child(user.qnectEmail).child("profileImage")
        
        
        userRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            
            if error != nil {
                completion(nil, error)
            }else {
                let image = UIImage(data: data!)
                completion(image, nil)
            }
        }
    }
    
    
    
    static func getProfileImageForCurrentUser() -> UIImage?
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let filePath = documentsURL.appendingPathComponent("profileImage").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)!
        }else {
            return nil
        }
    }
    
    
    static func saveContact(contact:User)
    {
        
        User.currentUser(userData: (FIRAuth.auth()?.currentUser)!) { (user) in
            
            let ref = FIRDatabase.database().reference()
            
 
            let userAddedContactsRef = ref.child("users").child((user.uid)).child("connectionsUserAdded").child(contact.uid)
            userAddedContactsRef.setValue(["firstName":contact.firstName, "lastName":contact.lastName, "socialPhone":contact.socialPhone, "socialEmail":contact.socialEmail, "username":contact.username, "qnectEmail":contact.qnectEmail, "uid":contact.uid])
            
            
            let contactsAddedUserRef = ref.child("users").child(contact.uid).child("connectionsAddedUser").child(user.uid)
            contactsAddedUserRef.setValue(["firstName":user.firstName, "lastName":user.lastName, "socialPhone":user.socialPhone, "socialEmail":user.socialEmail, "username":user.username, "qnectEmail":user.qnectEmail, "uid":user.uid])
            
            
        }
        
        
    
    }
    
    static func removeConnection(connection:User)
    {
        
        User.currentUser(userData: (FIRAuth.auth()?.currentUser)!) { (user) in
        
            let ref = FIRDatabase.database().reference()
            let userAddedContactsRef = ref.child("users").child((user.uid)).child("connectionsUserAdded").child(connection.uid)
        
            userAddedContactsRef.removeValue()
            
            let contactsAddedUserRef = ref.child("users").child(connection.uid).child("connectionsAddedUser").child(user.uid)
           
            contactsAddedUserRef.removeValue()
            
            
            
        }
        

    }
    
    static func signOut()
    {
        try! FIRAuth.auth()?.signOut()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("profileImage")

        try! FileManager().removeItem(at: fileURL)
        
        
    }
    
 
    
    

    
  
    
   
}
