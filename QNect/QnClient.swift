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
import ReachabilitySwift

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
        currentUserRef.updateChildValues([DatabaseFields.following.rawValue: 0])
        currentUserRef.updateChildValues([DatabaseFields.followers.rawValue: 0])
        
        
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
        
        let usersRef = ref.child(DatabaseFields.users.rawValue)
        let currentUserRef = usersRef.child(currentUser.uid)
        
        currentUserRef.updateChildValues([DatabaseFields.firstName.rawValue: firstName,
                                       DatabaseFields.lastName.rawValue: lastName])
        
        if let personalEmail = personalEmail, personalEmail != "" {
            currentUserRef.updateChildValues([DatabaseFields.personalEmail.rawValue: personalEmail])
        }else {
            currentUserRef.child(DatabaseFields.personalEmail.rawValue).removeValue()
        }
        if var phone = phone, phone != "" {
            phone = String(phone.characters.filter {"0123456789".characters.contains($0) })
            currentUserRef.updateChildValues([DatabaseFields.phone.rawValue: phone])
        }else {
            currentUserRef.child(DatabaseFields.phone.rawValue).removeValue()
        }
        if let location = location, location != "" {
            currentUserRef.updateChildValues([DatabaseFields.location.rawValue: location])
        }else {
            currentUserRef.child(DatabaseFields.location.rawValue).removeValue()
        }
        if let birthdate = birthdate, birthdate != "" {
            currentUserRef.updateChildValues([DatabaseFields.birthdate.rawValue: birthdate])
        }else {
            currentUserRef.child(DatabaseFields.birthdate.rawValue).removeValue()
        }
        
        if about == "About" || about == "" {
            currentUserRef.child(DatabaseFields.about.rawValue).removeValue()
        }else {
            currentUserRef.updateChildValues([DatabaseFields.about.rawValue: about!])
        }
    }

    func currentUser(completion: @escaping (User) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).observe(.value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                completion(user)
            }else {
            }
            
        })
    }
    
    
    func setProfileImage(image:UIImage)
    {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)
            if let jpgData = UIImageJPEGRepresentation(image, 0.5) {
                try jpgData.write(to: fileURL, options: .atomic)
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
        } catch let error {
            print(error)
        }
    }
    
    
    func getProfileImageForUser(user: User, began:(() -> Void), completion:@escaping (UIImage?, Error?) -> Void)
    {
        
        began()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        if currentUser.uid == user.uid {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let filePath = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue).path
            if FileManager.default.fileExists(atPath: filePath) {
                let image = UIImage(contentsOfFile: filePath)
                completion(image, nil)
                return
            }
        }
        
        guard Reachability.isConnectedToInternet() else {
            completion(nil, Oops.networkError)
            return
        }
        
        let storageRef = FIRStorage.storage().reference()
        
        let userStorageRef = storageRef.child(DatabaseFields.users.rawValue)
        let userRef = userStorageRef.child(user.email).child(DatabaseFields.profileImage.rawValue)
        
        userRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            
            if error != nil {
                completion(nil, error)
            }else {
                
                let image = UIImage(data: data!)
                if user.uid == currentUser.uid {
                    self.setProfileImage(image: image!)
                }
                completion(image, nil)
            }
        }
    }
    
    
    /// Gets most recent info of user passed in.
    ///
    /// - Parameters:
    ///   - user: Current user to get most recent info
    ///   - completion: pass back the updated user
    func getUpdatedInfoForUser(user: User, completion:@escaping (User) -> Void) {
        
        ref.child(DatabaseFields.users.rawValue).child(user.uid).observe(.value, with: { snapshot in
            if let updatedUser = User(snapshot: snapshot) {
                completion(updatedUser)
            }
        })
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
    
    fileprivate func  updateFollowing(value: Int) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).runTransactionBlock { (currentData) -> FIRTransactionResult in
            if var userInfo = currentData.value as? [String: AnyObject] {
                if var followingCount = userInfo[DatabaseFields.following.rawValue] as? Int {
                    followingCount += value
                    
                    userInfo[DatabaseFields.following.rawValue] = followingCount as AnyObject?
                    
                    currentData.value = userInfo
                    
                    
                }
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }
    }
    
    fileprivate func updateFollower(user: User,value: Int) {
        ref.child(DatabaseFields.users.rawValue).child(user.uid).runTransactionBlock { (currentData) -> FIRTransactionResult in
            if var userInfo = currentData.value as? [String: AnyObject] {
                if var followersCount = userInfo[DatabaseFields.followers.rawValue] as? Int {
                    followersCount += value
                    
                    userInfo[DatabaseFields.followers.rawValue] = followersCount as AnyObject?
                    
                    currentData.value = userInfo
                    
                }
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }
    }
    
    
    func follow(user: User, completion: ErrorCompletion)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        guard user.uid != currentUser.uid else {
            let error = Oops.customError("You cannot follow yourself 😜")
            completion(error)
            return
        }
      
        ref.child(DatabaseFields.following.rawValue).child(user.uid).queryEqual(toValue: FollowingStatus.blocking.rawValue, childKey: currentUser.uid).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                //current Useer is being blocked by user they want to follow, and we cannot allow them to follow them
                //show alert or something
                print("You are blocked from following this user")
            }else {
                //Can continue to follow process
                //If we are scanning directly from their phone private settings do not apply
                if user.isPrivate {
                    //Current user is requesting to follow user passed in
                    self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).updateChildValues([user.uid: FollowingStatus.pending.rawValue])
                    self.ref.child(DatabaseFields.followers.rawValue).child(user.uid).updateChildValues([currentUser.uid: FollowingStatus.pending.rawValue])
                    
                }else {
                    //Current user can automatically follow this user
                    //Because it is accepted right away, increment followingCount for currentUser
                    
                    self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).updateChildValues([user.uid: FollowingStatus.accepted.rawValue], withCompletionBlock: { (error, ref) in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                        }else {
                            self.updateFollowing(value: 1)
                        }
                    })
                    self.ref.child(DatabaseFields.followers.rawValue).child(user.uid).updateChildValues([currentUser.uid: FollowingStatus.accepted.rawValue], withCompletionBlock: { (error, ref) in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                        }else {
                            self.updateFollower(user: user, value: 1)
                        }
                    })

                    
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
        
        //Decrement following and follower count
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).removeValue { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }else {
                self.updateFollowing(value: -1)
            }
        }
        ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }else {
                self.updateFollower(user: user, value: -1)
            }
        }

    }
    
    func acceptFollowRequest(user: User)
    {
        
        //Increment following, and follower count
        
        let currentUser = FIRAuth.auth()!.currentUser!
        //Change status to following
        ref.child(DatabaseFields.following.rawValue).child(user.uid).updateChildValues([currentUser.uid: FollowingStatus.accepted])
        ref.child(DatabaseFields.followers.rawValue).child(currentUser.uid).updateChildValues([user.uid: FollowingStatus.accepted])
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
        
        //If currently following, decrement following and followers, 
        //else just remove values
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let status = snapshot.value as? String {
                if status == FollowingStatus.accepted.rawValue {
                    //Decrement following and follower count
                    self.updateFollower(user: user, value: -1)
                    self.updateFollowing(value: -1)
                  
                }
            }
        })
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).updateChildValues([user.uid: FollowingStatus.blocking.rawValue])
        
        //User passed in can still be followed by the current user, but user that is beign blocked can long see current users profile
        ref.child(DatabaseFields.following.rawValue).child(user.uid).child(currentUser.uid).removeValue()
        ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue()
        
    }
    
    func unblock(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).removeValue()
        ref.child(DatabaseFields.followers.rawValue).child(user.uid).child(currentUser.uid).removeValue()
    }
    
    func getFollowing(completion: @escaping (([User]) -> Void))  {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).observe(.value, with:  { snapshot in
            var users = [User]()
            
            if !snapshot.exists() {
                completion(users)
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                self.ref.child(DatabaseFields.users.rawValue).child(item.key).observe(.value, with: {snapshot in
                    print(item.key)
                    
                    
                    let user = User(snapshot: snapshot)!
                    
                    self.getProfileImageForUser(user: user, began: {}, completion: { (image,error) in
                        if image != nil {
                            user.profileImage = image
                        }
                        
                        let userUID = item.key
                        let followingStatus = item.value as! String
                        
                        //Do not re-add users
                        users = users.filter() {$0.uid != userUID }
                        if followingStatus == FollowingStatus.accepted.rawValue {
                            users.append(user)
                        }
                        
                        completion(users)
                    })
                    
                    
                })
            }
            
        })
    }
    
    func getFollowers(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.followers.rawValue).child(currentUser.uid).observe(.value, with: { snapshot in
            var users = [User]()
            
            if !snapshot.exists() {
                completion(users)
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                self.ref.child(DatabaseFields.users.rawValue).child(item.key).observe(.value, with: { (snapshot) in
                    if let user = User(snapshot: snapshot) {
                        self.getProfileImageForUser(user: user, began: {}, completion: { (image, error) in
                            if image != nil {
                                user.profileImage = image
                            }
                            
                            let userUID = item.key
                            let followingStatus = item.value as! String
                            
                            users = users.filter { $0.uid != userUID}
                            if followingStatus == FollowingStatus.accepted.rawValue {
                                users.append(user)
                            }
                            
                            completion(users)
                        })
                    }
                })
            }
        })
    }
    
    
    
    //MARK: User Stuff
    
    
    func signOut()
    {
        do {
           try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)

        
        
        do {
            try FileManager().removeItem(at: fileURL)
        }catch let error {
            print(error)
        }
        
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



