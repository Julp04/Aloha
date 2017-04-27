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

class QnClient {
    
    static let sharedInstance = QnClient()
    
    
     func setUserInfo(userInfo: UserInfo)
     {
        let ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()!.currentUser!
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.setValue(["username": userInfo.userName, "firstName": userInfo.firstName, "lastName": userInfo.lastName, "email": userInfo.email, "uid":user.uid])
        
        
        let username = ref.child("usernames")
        username.updateChildValues([userInfo.userName!: userInfo.email!])
    }
    
    
    func setUserInfoFor(user:FIRUser,username:String, firstName:String, lastName:String, personalEmail:String?, phone:String?, twitter:String?)
    {
        
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.setValue(["username":username, "firstName":firstName, "lastName":lastName, "personalEmail":phone,"phone":personalEmail, "email":user.email, "twitterScreenName":twitter, "uid":user.uid])
    }
    
    func updateUserInfo(firstName:String, lastName:String, personalEmail:String?, phone:String?)
    {
        let user = FIRAuth.auth()!.currentUser!
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.updateChildValues(["firstName": firstName, "lastName": lastName, "personalEmail": personalEmail ?? "","phone": phone ?? ""])
    }
    
    func updateUserInfo(personalEmail:String?, phone:String?)
    {
        let user = FIRAuth.auth()!.currentUser!
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.updateChildValues(["personalEmail": personalEmail ?? "","phone": phone ?? ""])
    }
    
    func currentUser(completion: @escaping (User) -> Void)
    {
        let ref = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("users").child(currentUser.uid).observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            completion(user)
        })
    }
    
    
    func setProfileImage(image:UIImage)
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
    
    
    func getProfileImageForUser(user:User, completion:@escaping (UIImage?, Error?) ->Void)
    {
        let storageRef = FIRStorage.storage().reference()
        
        
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child(user.email).child("profileImage")
        
        userRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            
            if error != nil {
                completion(nil, error)
            }else {
                let image = UIImage(data: data!)
                completion(image, nil)
            }
        }
    }
    
    func getProfileImageForCurrentUser() -> UIImage?
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let filePath = documentsURL.appendingPathComponent("profileImage").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)!
        }else {
            return nil
        }
    }
    
    
    func followUser(user:User)
    { 
        
        
    
    }
    
    func unfollowUser(connection:User)
    {
        
    }
    
    func signOut()
    {
        try! FIRAuth.auth()?.signOut()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("profileImage")

//        try! FileManager().removeItem(at: fileURL)
        
    }
    
    func deleteUser(completion:@escaping (Error) -> Void) {
        //todo: Needs to be tested thoroughly with internet and without
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        QnClient.sharedInstance.currentUser { (user) in
            let userName = user.username!
            let uid = user.uid!
            
            
            currentUser.delete(completion: { (error) in
                guard error == nil else {
                    completion(error!)
                    return
                }
                
                TwitterClient().unlinkTwitter(completion: { (error) in
                    if error != nil {
                        completion(error!)
                    }
                })
                
                //No error remove, all other traces of this user from database
                let ref = FIRDatabase.database().reference()
                ref.child("usernames").child(userName).removeValue()
                
                //Remove profile picture locally and on database
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("profileImage")
                try! FileManager().removeItem(at: fileURL)
                
                ref.child("users").child(uid).removeValue()
                
            })
        }
        
      
    }
    
    func doesTwitterUserExistsWith(session:TWTRSession, completion:@escaping (Bool) -> Void)
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
    
   
}



