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
import Alamofire

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
    
    private var ref: FIRDatabaseReference
    
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

    func currentUser(completion: @escaping (User?) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let userRef = ref.child(DatabaseFields.users.rawValue).child(currentUser.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                completion(user)
            }else {
                print("User not available")
                QnClient.sharedInstance.signOut()
                completion(nil)
            }
            
        })
    }
    
    
    func setProfileImage(image: UIImage)
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
            let userRef = userStorageRef.child((FIRAuth.auth()!.currentUser!.uid))
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
        
        began()
        if let url = user.profileImageURL {
            ImageDownloader.downloadImage(url: url, completion: { (result) in
                switch result {
                case .success(let image):
                    if user.uid == currentUser.uid {
                        self.setProfileImage(image: image!)
                    }
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    
    /// Gets most recent info of user passed in.
    ///
    /// - Parameters:
    ///   - user: Current user to get most recent info
    ///   - completion: pass back the updated user
    func getUpdatedInfoForUser(user: User, completion:@escaping (User) -> Void) {
        
        let userRef = ref.child(DatabaseFields.users.rawValue).child(user.uid)
        
        userRef.observe(.value, with: { snapshot in
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

        let followingRef = ref.child("following").child(currentUser.uid).child(user.uid)
        let blockingRef = ref.child("blocking").child(currentUser.uid).child(user.uid)
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? NSDictionary {
                if let status = values["following"] as? Bool {
                    if status {
                        completion(.accepted)
                        return
                    }else {
                        completion(.pending)
                        return
                    }
                }
            }
            blockingRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    completion(.blocking)
                    return
                }else {
                    completion(.notFollowing)
                    return
                }
            })
        })

    }
    
    func getFollowStatus(user: User, completion: @escaping (FollowingStatus) -> Void) {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let followingRef = ref.child("following").child(currentUser.uid).child(user.uid)
        let blockingRef = ref.child("blocking").child(currentUser.uid).child(user.uid)
        
        followingRef.observe(.value, with: { (snapshot) in

            if let values = snapshot.value as? NSDictionary {
                if let status = values["following"] as? Bool {
                    if status {
                        completion(.accepted)
                        return
                    }else {
                        completion(.pending)
                        return
                    }
                }
            }
            blockingRef.observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    completion(.blocking)
                    return
                }else {
                    completion(.notFollowing)
                    return
                }
            })
        })
    }
    
    func follow(user: User, completion: @escaping ErrorCompletion)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        let followingRef = ref.child("following").child(currentUser.uid)
        let followersRef = ref.child("followers").child(user.uid)
        
        guard user.uid != currentUser.uid else {
            let error = Oops.customError("You cannot follow yourself 😜")
            completion(error)
            return
        }
    
        //If we are scanning directly from their phone private settings do not apply
        if user.isPrivate {
            //Current user is requesting to follow user passed in
            
            followingRef.child(user.uid).updateChildValues(["following": false])
            followersRef.child(currentUser.uid).updateChildValues(["follower": false])
            
        }else {
            //Current user can automatically follow this user
            followingRef.child(user.uid).updateChildValues(["following": true, "date": Date().asString()])
            followersRef.child(currentUser.uid).updateChildValues(["follower": true, "date": Date().asString()])
        }
        
        completion(nil)
    }

    func cancelFollow(user: User, completion: @escaping ErrorCompletion)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child("following").child(currentUser.uid).child(user.uid).removeValue()
        self.ref.child("followers").child(user.uid).child(currentUser.uid).removeValue()
        
        completion(nil)
    }
    
    func unfollow(user: User, completion: @escaping ErrorCompletion)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("following").child(currentUser.uid).child(user.uid).removeValue()
        ref.child("followers").child(user.uid).child(currentUser.uid).removeValue()
        completion(nil)
    }
    
    func acceptFollowRequest(user: User, completion: @escaping (Error?) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        //Change status to following
        ref.child("following").child(user.uid).child(currentUser.uid).updateChildValues(["following": true, "date": Date().asString()])
        ref.child("followers").child(currentUser.uid).child(user.uid).updateChildValues(["follower": true, "date": Date().asString()])
        completion(nil)
    }
    
    func denyFollowRequest(user: User, completion: @escaping (Error?) -> Void)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        //Do not change following status
        
        //Delete request
        ref.child("followers").child(user.uid).child(currentUser.uid).removeValue()
        ref.child("following").child(currentUser.uid).child(user.uid).removeValue()
        completion(nil)
    }
    
    func block(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        self.ref.child("blocking").child(currentUser.uid).updateChildValues([user.uid: true])
        
        self.ref.child("following").child(currentUser.uid).child(user.uid).removeValue()
        self.ref.child("followers").child(user.uid).child(currentUser.uid).removeValue()
        
        //user being blocked is not allowed to follow current user anymore
        self.ref.child("following").child(user.uid).child(currentUser.uid).removeValue()
        self.ref.child("followers").child(currentUser.uid).child(user.uid).removeValue()
 
    }
    
    func unblock(user: User)
    {
        let currentUser = FIRAuth.auth()!.currentUser!
        ref.child("blocking").child(currentUser.uid).child(user.uid).removeValue()
    }
    
    func isBlockedBy(user: User, completion: @escaping (Bool) -> Void) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("blocking").child(user.uid).child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    //todo: Don't like this name because its not like added but following..
    func getRecentlyAdded(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
    
        ref.child("following").child(currentUser.uid).queryOrdered(byChild: "following").queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            
            var users = [User]()
            if !snapshot.exists() {
                
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                let values = item.value as! NSDictionary
                let status = values["following"] as! Bool
                let dateAddedString = values["date"] as! String
                
                
                guard let dateAdded = dateAddedString.asDate() else {
                    completion(users)
                    return
                }
                
                
                
                let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                let endDate = Calendar.current.date(byAdding: .day, value: +1, to: Date())!
                
                print("Start date is " + startDate.asString())
                print("End date is " + endDate.asString())
                
                //If the date they were added does not fall in between these dates, then that means they were not recently added.
                //In our case recently added is within one week from the current day
                guard (startDate...endDate).contains(dateAdded) else {
                    completion(users)
                    return
                }
                
                //IF status is false that means it is pending and not actually following
                guard status else {
                    completion(users)
                    return
                }
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                            users = users.filter() {$0.uid != userID }
                            users.append(user)
                            
                            completion(users)
                    }
                })
            }
            
        })
    }
    
    
    func getFollowing(forUser user: User, completion: @escaping (([User]) -> Void))  {
       
        
        ref.child("following").child(user.uid).queryOrdered(byChild: "following").queryEqual(toValue: true).observe(.value, with: { (snapshot) in
             var users = [User]()
            
            if !snapshot.exists() {
                
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                let values = item.value as! NSDictionary
                let status = values["following"] as! Bool
                
                //IF status is false that means it is pending and not actually following
                guard status else {
                    completion(users)
                    return
                }
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                        users = users.filter() {$0.uid != userID }
                        users.append(user)
                        
                        completion(users)
                    }
                })
            }
        })
    }
    
    func getFollowing(completion: @escaping (([User]) -> Void))  {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        ref.child("following").child(currentUser.uid).queryOrdered(byChild: "following").queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            
            var users = [User]()
            
            if !snapshot.exists() {
                
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                let values = item.value as! NSDictionary
                let status = values["following"] as! Bool
                
                //IF status is false that means it is pending and not actually following
                guard status else {
                    completion(users)
                    return
                }
                
                self.ref.child(DatabaseFields.users.rawValue).child(userID).observeSingleEvent(of: .value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                            users = users.filter() {$0.uid != userID }
                            users.append(user)
                            
                            completion(users)
                        }
                })
            }
        })
    }
    
    func getFollowers(forUser user: User, completion: @escaping (([User]) -> Void)) {
        
        
        ref.child("followers").child(user.uid).queryOrdered(byChild: "follower").queryEqual(toValue: true).observe(.value, with: { (snapshot) in

            var users = [User]()
            if !snapshot.exists() {
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                let userRef = self.ref.child(DatabaseFields.users.rawValue).child(userID)
//                self.allRefs.append(userRef)
                
                userRef.observe(.value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                            //Do not re-add users
                            users = users.filter() {$0.uid != userID }
                            users.append(user)
                            
                            
                            completion(users)
                    }else {
                        assertionFailure()
                    }
                })
            }
        })
    }
    
    
    func getFollowers(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
        var users = [User]()
        
        ref.child("followers").child(currentUser.uid).queryOrdered(byChild: "follower").queryEqual(toValue: true).observe(.value, with: { (snapshot) in
            
            if !snapshot.exists() {
                completion(users)
                return
            }
            
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let userID = item.key
                
                let userRef = self.ref.child(DatabaseFields.users.rawValue).child(userID)
//                self.allRefs.append(userRef)
                
                userRef.observe(.value, with: { snapshot in
                    if let user = User(snapshot: snapshot) {
                            //Do not re-add users
                        users = users.filter() {$0.uid != userID }
                        users.append(user)
                            
                            
                        completion(users)
                    }else {
                        assertionFailure()
                    }
                })
            }
        })
    }
    
    func getFollowRequests(completion: @escaping (([User]) -> Void)) {
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("followers").child(currentUser.uid).queryOrdered(byChild: "follower").queryEqual(toValue: false).observe(.value, with: { (snapshot) in
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
    
    
    /// Deletes current user from Aloha. Unlinks all accounts and removes all info from database. Cloud functions is handled when user is successfully deleted to remove all instances of user on database
    ///
    /// - Parameter completion: returns success or failure
    func deleteCurrentUser(completion:@escaping (Result<Any?>) -> Void) {
       //Delete photo in storage in database
        let storageRef = FIRStorage.storage().reference()
        let userStorageRef = storageRef.child(DatabaseFields.users.rawValue)
        userStorageRef.child((FIRAuth.auth()?.currentUser?.uid)!).child(DatabaseFields.profileImage.rawValue).delete { (error) in
            if error != nil {
                //Error deleting file from database
                completion(.failure(error!))
            }else {
                //Success
                TwitterClient.client.unlinkTwitter(completion: { (result) in
                    switch result {
                    case .success(nil):
                        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                            if let error = error {
                                completion(.failure(error))
                            }else {
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let fileURL = documentsURL.appendingPathComponent(DatabaseFields.profileImage.rawValue)
                                do {
                                    try FileManager().removeItem(at: fileURL)
                                }catch _ {
                                }
                            }})
                        completion(.success(error))
                        break
                    case .failure(let error):
                        completion(.failure(error))
                    default:
                        break
                    }
                })
            }
        }
    }
    func add(scan: Scan) {
        let currentUser = FIRAuth.auth()!.currentUser!
        ref.child("scans").child(currentUser.uid).childByAutoId().updateChildValues(["data": scan.data, "date": scan.date.asString()])
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
    
    
    func reportUser(user: User, type: ReportType, completion: @escaping (Result<Any>) -> Void) {
        Alamofire.request("https://us-central1-aloha-dev.cloudfunctions.net/reportUser", method: .post, parameters: ["uid": user.uid, "reportingType": type.rawValue], encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            
            if let error = response.result.error {
                completion(.failure(error))
            }else {
                completion(.success("success"))
            }
        }
    }
}

enum ReportType: String {
    case spam = "Spam"
    case inappropriate = "Inappropriate"
}





