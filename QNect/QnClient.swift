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

enum DatabaseFields: String {
    case username = "username"
    case firstName = "firstName"
    case lastName = "lastName"
    case email = "email"
    case uid = "uid"
    case location = "location"
    case personalEmail = "personalEmail"
    case phone = "phone"
    case about = "about"
    case birthdate = "birthdate"
    
    case profileImage = "profileImage"
    case users = "users"
    case usernames = "usernames"
}

class QnClient {
    
    static let sharedInstance = QnClient()
    
    
     func setUserInfo(userInfo: UserInfo)
     {
        let ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()!.currentUser!
        let users = ref.child(DatabaseFields.users.rawValue)
        let currentUser = users.child(user.uid)
        
        currentUser.setValue([DatabaseFields.username.rawValue: userInfo.userName,
                              DatabaseFields.firstName.rawValue: userInfo.firstName,
                              DatabaseFields.lastName.rawValue: userInfo.lastName,
                              DatabaseFields.email.rawValue: userInfo.email,
                              DatabaseFields.uid.rawValue: user.uid])
        
        
        let username = ref.child(DatabaseFields.usernames.rawValue)
        username.updateChildValues([userInfo.userName!: userInfo.email!])
    }
    
    func updateUserInfo(firstName:String, lastName:String, personalEmail:String?, phone:String?, location: String?, birthdate: String?, about: String?)
    {
        let user = FIRAuth.auth()!.currentUser!
        let ref = FIRDatabase.database().reference()
        let users = ref.child(DatabaseFields.users.rawValue)
        let currentUser = users.child(user.uid)
        
        currentUser.updateChildValues([DatabaseFields.firstName.rawValue: firstName,
                                       DatabaseFields.lastName.rawValue: lastName])
        
        if let personalEmail = personalEmail {
            currentUser.updateChildValues([DatabaseFields.personalEmail.rawValue: personalEmail])
        }
        if var phone = phone {
            phone = String(phone.characters.filter {"0123456789".characters.contains($0) })
            
            currentUser.updateChildValues([DatabaseFields.phone.rawValue: phone])
        }
        if let location = location {
            currentUser.updateChildValues([DatabaseFields.location.rawValue: location])
        }
        if let birthdate = birthdate {
            currentUser.updateChildValues([DatabaseFields.birthdate.rawValue: birthdate])
        }
        if var about = about  {
            if about == "About" {
                about = ""
            }
            
            currentUser.updateChildValues([DatabaseFields.about.rawValue: about])
        }
    }

    func currentUser(completion: @escaping (User) -> Void)
    {
        let ref = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()!.currentUser!
        print(currentUser.uid)
        
        ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            completion(user)
        })
    }
    
    
    func setProfileImage(image:UIImage)
    {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            
            // Get a reference to the storage service using the default Firebase App
            let storageRef = FIRStorage.storage().reference()
            
            // Create a storage reference from our storage service
            let userStorageRef = storageRef.child(DatabaseFields.users.rawValue)
            let userRef = userStorageRef.child((FIRAuth.auth()?.currentUser?.email)!)
            let profileImageRef = userRef.child(DatabaseFields.profileImage.rawValue)
            
            
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
        
        
        let userStorageRef = storageRef.child(DatabaseFields.users.rawValue)
        let userRef = userStorageRef.child(user.email).child(DatabaseFields.profileImage.rawValue)
        
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
        
        let filePath = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue).path
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
        do {
           try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)

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
                ref.child(DatabaseFields.usernames.rawValue).child(userName).removeValue()
                
                //Remove profile picture locally and on database
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)
                try! FileManager().removeItem(at: fileURL)
                
                ref.child(DatabaseFields.users.rawValue).child(uid).removeValue()
                
            })
        }
    }
}



