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
import Fabric
import TwitterKit
import OAuthSwift

class QnUtilitiy {
    
    
    static func setUserInfoFor(user:FIRUser,username:String, firstName:String, lastName:String, socialEmail:String?, socialPhone:String?, twitter:String?)
    {
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        let uidRef = usersRef.child(user.uid)
        let userInfoRef = uidRef.child("userInfo")
        
        userInfoRef.setValue(["username":username, "firstName":firstName, "lastName":lastName, "socialEmail":socialEmail,"socialPhone":socialPhone, "qnectEmail":user.email, "twitter":twitter])
    }
    
    
    static func updateUserInfo(firstName:String, lastName:String, socialEmail:String?, socialPhone:String?)
    {
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let currentUser = FIRAuth.auth()?.currentUser!
        let uidRef = usersRef.child((currentUser?.uid)!)
        let userInfoRef = uidRef.child("userInfo")
        
        userInfoRef.updateChildValues(["firstName":firstName, "lastName":lastName, "socialPhone":socialPhone!, "socialEmail":socialEmail!])
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
        
        User.currentUser(completion: { (user) in
            
            let ref = FIRDatabase.database().reference()
            
 
            let userAddedContactsRef = ref.child("users").child((user.uid)).child("connectionsUserAdded").child(contact.uid)
            userAddedContactsRef.setValue(["firstName":contact.firstName, "lastName":contact.lastName, "socialPhone":contact.socialPhone, "socialEmail":contact.socialEmail, "username":contact.username, "qnectEmail":contact.qnectEmail, "uid":contact.uid])
            
            
            let contactsAddedUserRef = ref.child("users").child(contact.uid).child("connectionsAddedUser").child(user.uid)
            contactsAddedUserRef.setValue(["firstName":user.firstName, "lastName":user.lastName, "socialPhone":user.socialPhone, "socialEmail":user.socialEmail, "username":user.username, "qnectEmail":user.qnectEmail, "uid":user.uid])
            
            
        })
        
        
    
    }
    
    static func removeConnection(connection:User)
    {
        
        User.currentUser(completion: { (user) in
        
            let ref = FIRDatabase.database().reference()
            let userAddedContactsRef = ref.child("users").child((user.uid)).child("connectionsUserAdded").child(connection.uid)
        
            userAddedContactsRef.removeValue()
            
            let contactsAddedUserRef = ref.child("users").child(connection.uid).child("connectionsAddedUser").child(user.uid)
           
            contactsAddedUserRef.removeValue()
            
            
            
        })
        

    }
    
    static func signOut()
    {
        try! FIRAuth.auth()?.signOut()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("profileImage")

        try! FileManager().removeItem(at: fileURL)
        
        
    }
    
    static func doesTwitterUserExistsWith(session:TWTRSession, completion:@escaping (Bool) -> Void)
    {
        
        let ref = FIRDatabase.database().reference()
        

        
        let usersRef = ref.child("users")
        let uidRef = usersRef.child((FIRAuth.auth()?.currentUser?.uid)!)
        let userInfoRef = uidRef.child("userInfo")
        
        userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {
                completion(false)
            }else {
            
                let snapshotValue = snapshot.value as! [String: AnyObject]
                let twitterUsername = snapshotValue["twitter"] as? String
                
                if twitterUsername == session.userName {
                    completion(true)
                }else {
                    completion(false)
                }
            }
        })
        
        
    }
    
    static func followUserOnTwitter(twitterUsername:String)
    {
        let client = TWTRAPIClient()
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/friendships/create.json"
        let params = ["user_id": "1401881", "follow":"true"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "POST", url: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
            }
            
            if data == nil {
                print("No data")
            }else {
                let json = JSON(data!)
                print(json)
            }
        }
    }
    
    
    
 
    
    

    
  
    
   
}
