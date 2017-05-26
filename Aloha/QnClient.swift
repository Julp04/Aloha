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

public enum Result <T> {
    case success(T)
    case failure(Error)
}

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
    
    case time = "time"
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
        
        ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                completion(user)
            }else {
            }
            
        })
    }
    
    
    func setProfileImage(image:UIImage)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
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
                    
                    let url = metadata!.downloadURL()!.absoluteString
                    self.ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).updateChildValues(["photoURL": url])
                    
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    
    func getProfileImageForUser(user: User, began:(() -> Void), completion:@escaping (Result<UIImage?>) -> Void)
    {
        
        began()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        if currentUser.uid == user.uid {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let filePath = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue).path
            if FileManager.default.fileExists(atPath: filePath) {
                let image = UIImage(contentsOfFile: filePath)
                completion(.success(image))
                return
            }
        }
        
        guard Reachability.isConnectedToInternet() else {
            completion(.failure(Oops.networkError))
            return
        }
        
        if let url = user.profileImageURL {
            ImageDownloader.downloadImage(url: url, completion: { (result) in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
//
    
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
    
    func getUpdatedInfoForUserOnce(user: User, completion:@escaping (User) -> Void) {
        
        ref.child(DatabaseFields.users.rawValue).child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let updatedUser = User(snapshot: snapshot) {
                completion(updatedUser)
            }
        })
    }

    func getFollowStatusOnce(user: User, completion:@escaping (FollowingStatus) -> Void) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child("people").child(currentUser.uid).child("following").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            if let status = snapshot.value as? Bool {
                if status {
                    completion(.accepted)
                }else {
                    completion(.pending)
                }
            }else {
                self.ref.child("people").child(currentUser.uid).child("blocking").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        completion(.blocking)
                    }else {
                        completion(.notFollowing)
                    }
                })
            }
        })
    }
    
    func getFollowStatus(user: User, completion: @escaping (FollowingStatus) -> Void) {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child("people").child(currentUser.uid).child("following").child(user.uid).observe(.value, with: { (snapshot) in
           
            
            if let status = snapshot.value as? Bool {
                if status {
                    completion(.accepted)
                }else {
                    completion(.pending)
                }
            }else {
                self.ref.child("people").child(currentUser.uid).child("blocking").child(user.uid).observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                        completion(.blocking)
                    }else {
                        completion(.notFollowing)
                    }
                })
            }
        })
    }
    
    fileprivate func  updateFollowing(user: User ,value: Int) {
        
        ref.child(DatabaseFields.users.rawValue).child(user.uid).runTransactionBlock { (currentData) -> FIRTransactionResult in
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
    
    
    func follow(user: User, completion: @escaping ErrorCompletion)
    {
        let date = Date().timeIntervalSince1970
        let currentUser = FIRAuth.auth()!.currentUser!
        
        guard user.uid != currentUser.uid else {
            let error = Oops.customError("You cannot follow yourself 😜")
            completion(error)
            return
        }
    
        //If we are scanning directly from their phone private settings do not apply
        if user.isPrivate {
            //Current user is requesting to follow user passed in
            
            self.ref.child("people").child(currentUser.uid).child("following").updateChildValues([user.uid: false])
            self.ref.child("people").child(user.uid).child("followers").updateChildValues([currentUser.uid: false], withCompletionBlock: { (error, ref) in
                completion(error)
            })
            
        }else {
            //Current user can automatically follow this user
            //Because it is accepted right away, increment followingCount for currentUser
            
            self.ref.child("people").child(currentUser.uid).child("following").updateChildValues([user.uid: true]) {error, ref in
                self.currentUser(completion: { (currentUser) in
                    self.updateFollowing(user: currentUser, value: 1)
                })
            }
            self.ref.child("people").child(user.uid).child("followers").updateChildValues([currentUser.uid: true], withCompletionBlock: { (error, ref) in
                completion(nil)
                self.updateFollower(user: user, value: 1)
            })
        }
    }

    func cancelFollow(user: User, completion: @escaping ErrorCompletion)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child("people").child(currentUser.uid).child("following").child(user.uid).removeValue()
        self.ref.child("people").child(user.uid).child("followers").child(currentUser.uid).removeValue { (error, ref) in
            completion(error)
        }
    }
    
    func unfollow(user: User, completion: @escaping ErrorCompletion)
    {
        
        //Decrement following and follower count
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("people").child(currentUser.uid).child("following").child(user.uid).removeValue { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }else {
                self.currentUser(completion: { (currentUser) in
                    self.updateFollowing(user: currentUser, value: -1)
                })
            }
            completion(error)
        }
        ref.child("people").child(user.uid).child("followers").child(currentUser.uid).removeValue { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }else {
                self.updateFollower(user: user, value: -1)
            }
        }

    }
    
    func acceptFollowRequest(user: User, completion: @escaping (Error?) -> Void)
    {
        //Increment following, and follower count
        self.currentUser { (currentUser) in
            self.updateFollower(user: currentUser, value: 1)
            self.updateFollowing(user: user, value: 1)
        }
      
        
        let currentUser = FIRAuth.auth()!.currentUser!
        //Change status to following
        ref.child("people").child(user.uid).child("following").updateChildValues([currentUser.uid: true])
        ref.child("people").child(currentUser.uid).child("followers").updateChildValues([user.uid: true]) { (error, ref) in
            completion(error)
        }
    }
    
    func denyFollowRequest(user: User, completion: @escaping (Error?) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        //Do not change following status
        
        //Delete request
        ref.child("people").child(user.uid).child("followers").child(currentUser.uid).removeValue()
        ref.child("people").child(currentUser.uid).child("following").child(user.uid).removeValue { (error, ref) in
            completion(error)
        }
    }
    
    func block(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        //If currently following, decrement following and followers, 
        //else just remove values
        self.currentUser { (currentUser) in
            self.ref.child(DatabaseFields.following.rawValue).child(currentUser.uid).child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                if let values = snapshot.value as? NSDictionary {
                    if let status = values["status"] as? String {
                        if status == FollowingStatus.accepted.rawValue {
                            //Decrement following and follower count
                            self.updateFollower(user: user, value: -1)
                            self.updateFollowing(user: currentUser, value: -1)
                            
                        }
                    }
                }
            })
        }
        
       
        ref.child("people").child(currentUser.uid).child("blocking").updateChildValues([user.uid: true])
        
        ref.child("people").child(currentUser.uid).child("following").child(user.uid).removeValue()
        ref.child("people").child(user.uid).child("followers").child(currentUser.uid).removeValue()
        
        //user being blocked is not allowed to follow current user anymore
        ref.child("people").child(user.uid).child("following").child(currentUser.uid).removeValue()
    }
    
    func unblock(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("people").child(currentUser.uid).child("blocking").child(user.uid).removeValue()
    }
    
    func isBlockedBy(user: User, completion: @escaping (Bool) -> Void) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("people").child(user.uid).child("blocking").child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                completion(false)
                return
            }

            completion(true)
        })
    }
    
    
    func getFollowing(completion: @escaping (([User]) -> Void))  {
        let currentUser = FIRAuth.auth()!.currentUser!
        var users = [User]()
        
        ref.child("people").child(currentUser.uid).child("following").queryOrderedByValue().queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                let status = item.value as! Bool
                
                //IF status is false that means it is pending and not actually following
                guard status else {
                    completion(users)
                    return
                }
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                        ImageDownloader.downloadImage(url: user.profileImageURL!, completion: { (result) in
                            switch result {
                            case .success(let image):
                                user.profileImage = image
                            case .failure(_):
                                break
                            }
                        })
                            //Do not re-add users
                            users = users.filter() {$0.uid != userID }
                            users.append(user)
                            completion(users)
                        }
                })
            }
        })
    }
    
    func getFollowers(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
        var users = [User]()
        
        ref.child("people").child(currentUser.uid).child("followers").queryOrderedByValue().queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                        self.getProfileImageForUser(user: user, began: {}, completion: { (result) in
                            switch result {
                            case .success(let image):
                                user.profileImage = image
                            case .failure( _):
                                break
                            }
                            
                            //Do not re-add users
                            users = users.filter() {$0.uid != userID }
                            users.append(user)
                            completion(users)
                            
                        })
                    }else {
                        assertionFailure()
                    }
                })
            }
        })
    }
    
    func getFollowRequests(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("people").child(currentUser.uid).child("followers").queryOrderedByValue().queryEqual(toValue: false).observe(.value, with: { (snapshot) in
            var users = [User]()
            
            if !snapshot.exists() {
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let user = User(snapshot: snapshot) {
                        self.getProfileImageForUser(user: user, began: {}, completion: { (result) in
                            switch result {
                            case .success(let image):
                                user.profileImage = image
                            case .failure(_):
                                break
                            }
                            
                            users.append(user)
                            completion(users)
                        })
                    }
                })
            }
        })
    }
    
    
    //MARK: User Stuff
    
    func updatePrivateMode(isPrivate: Bool) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child(DatabaseFields.users.rawValue).child(currentUser.uid).updateChildValues(["isPrivate": isPrivate])
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

        
        
        do {
            try FileManager().removeItem(at: fileURL)
        }catch let error {
            print(error)
        }
        
    }
    
    func deleteCurrentUser(completion:@escaping (Error) -> Void) {
        //todo: Needs to be tested thoroughly with internet and without
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.currentUser { (user) in
            let userName = user.username!
            let uid = user.uid!
            
//            
//            currentUser.delete(completion: { (error) in
//                guard error == nil else {
//                    completion(error!)
//                    return
//                }
//                
//                TwitterClient().unlinkTwitter(completion: { (error) in
//                    if error != nil {
//                        completion(error!)
//                    }
//                })
//                
//                //No error remove, all other traces of this user from database
//                let ref = FIRDatabase.database().reference()
//                ref.child(DatabaseFields.usernames.rawValue).child(userName).removeValue()
//                
//                //Remove profile picture locally and on database
//                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)
//                do {
//                    try FileManager().removeItem(at: fileURL)
//                }catch let error {
//                    print(error)
//                }
//                
//                ref.child(DatabaseFields.users.rawValue).child(uid).removeValue()
//                ref.child(DatabaseFields.followers.rawValue).child(uid).removeValue()
//                ref.child(DatabaseFields.following.rawValue).child(uid).removeValue()
            
            
            
        }
    }
    
    func unlinkAllAccounts() {
        
        TwitterClient.client.unlinkTwitter { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
        
        
    }
}





