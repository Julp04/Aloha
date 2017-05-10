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
    
    case following = "following"
    case followers = "followers"
    case blocking = "blocking"
    
    case isPrivate = "isPrivate"
    case status = "status"
}

enum FollowingStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case blocking = "blocking"
    case notFollowing = "notFollowing"
}

class QnClient {
    
    var ref: FIRDatabaseReference
    static let sharedInstance = QnClient()
    
    init() {
        ref = FIRDatabase.database().reference()
    }
    
     func setUserInfo(userInfo: UserInfo)
     {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let usersRef = ref.child(DatabaseFields.users.rawValue)
        let currentUserRef = usersRef.child(currentUser.uid)
        
        currentUserRef.setValue([DatabaseFields.username.rawValue: userInfo.userName,
                              DatabaseFields.firstName.rawValue: userInfo.firstName,
                              DatabaseFields.lastName.rawValue: userInfo.lastName,
                              DatabaseFields.email.rawValue: userInfo.email,
                              DatabaseFields.uid.rawValue: currentUser.uid])
        //User will always be public unless changed by user
        currentUserRef.updateChildValues([DatabaseFields.isPrivate.rawValue: false])
        
        
        let usernameRef = ref.child(DatabaseFields.usernames.rawValue)
        usernameRef.updateChildValues([userInfo.userName!: userInfo.email!])
    }
    
    func changePrivacySettingsForUser(isPrivate: Bool) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let usersRef = ref.child(DatabaseFields.users.rawValue)
        let currentUserRef = usersRef.child(currentUser.uid)
        
        currentUserRef.updateChildValues([DatabaseFields.isPrivate.rawValue: isPrivate])
    }
    
    func updateUserInfo(firstName:String, lastName:String, personalEmail:String?, phone:String?, location: String?, birthdate: String?, about: String?)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let users = ref.child(DatabaseFields.users.rawValue)
        let currentUserRef = users.child(currentUser.uid)
        
        currentUserRef.updateChildValues([DatabaseFields.firstName.rawValue: firstName,
                                       DatabaseFields.lastName.rawValue: lastName])
        
        if let personalEmail = personalEmail {
            currentUserRef.updateChildValues([DatabaseFields.personalEmail.rawValue: personalEmail])
        }
        if var phone = phone {
            phone = String(phone.characters.filter {"0123456789".characters.contains($0) })
            
            currentUserRef.updateChildValues([DatabaseFields.phone.rawValue: phone])
        }
        if let location = location {
            currentUserRef.updateChildValues([DatabaseFields.location.rawValue: location])
        }
        if let birthdate = birthdate {
            currentUserRef.updateChildValues([DatabaseFields.birthdate.rawValue: birthdate])
        }
        if var about = about  {
            if about == "About" {
                about = ""
            }
            
            currentUserRef.updateChildValues([DatabaseFields.about.rawValue: about])
        }
    }

    func currentUser(completion: @escaping (User) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let user = FIRAuth.auth()!.currentUser!
        
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
    
    func getFollowStatus(user: User, completion: @escaping (FollowingStatus) -> Void) {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).observe(.value, with: {snapshot in
            if let status = snapshot.value as? String {
                switch status {
                case FollowingStatus.accepted.rawValue:
                    completion(.accepted)
                case FollowingStatus.blocking.rawValue:
                    completion(.blocking)
                case FollowingStatus.pending.rawValue:
                    completion(.pending)
                default:
                    completion(.notFollowing)
                }
            }else {
                completion(.notFollowing)
            }
        })
        
    }
    
    func follow(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        
        ref.child(DatabaseFields.following.rawValue).child(user.uid).queryEqual(toValue: FollowingStatus.blocking.rawValue, childKey: currentUser.uid).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                //current Useer is being blocked by user they want to follow, and we cannot allow them to follow them
                //show alert or something
            }else {
                user.isPrivate = true
                //Can continue to follow process
                //If we are scanning directly from their phone private settings do not apply
                if user.isPrivate {
                    //Current user is requesting to follow user passed in
                    self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).setValue([user.uid: FollowingStatus.pending.rawValue])
                    self.ref.child(DatabaseFields.followers.rawValue).child(user.uid).setValue([currentUser.uid: FollowingStatus.pending.rawValue])
                }else {
                    //Current user can automatically follow this user
                    self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).setValue([user.uid: FollowingStatus.accepted.rawValue])
                    self.ref.child(DatabaseFields.followers.rawValue).child(user.uid).setValue([currentUser.uid: FollowingStatus.accepted.rawValue])
                    
                }
                
                
            }
        })
    }
    
    func cancelFollow(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).removeValue()
        self.ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue()
    }
    
    func unfollow(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).removeValue()
        
        ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue()
    }
    
    func acceptFollowRequest(user: User)
    {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        //Change status to following
        ref.child(DatabaseFields.following.rawValue).child(user.uid).updateChildValues([currentUser.uid: FollowingStatus.accepted])
        ref.child(DatabaseFields.followers.rawValue).child(currentUser.uid).updateChildValues([user.uid: FollowingStatus.accepted])
        
        //Delete Request
    }
    
    func denyFollowRequest(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        //Do not change following status
        
        //Delete request
    }
    
    func block(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).setValue([user.uid: FollowingStatus.blocking.rawValue])
        
        //User passed in can still be followed by the current user, but user that is beign blocked can long see current users profile
        ref.child(DatabaseFields.following.rawValue).child(user.uid).child(currentUser.uid).removeValue()
    }
    
    func unblock(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).removeValue()
        ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue()
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
    
    func deleteCurrentUser(completion:@escaping (Error) -> Void) {
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



