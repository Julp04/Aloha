//
//  Social.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/16/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift
import Accounts
import FirebaseDatabase
import FirebaseAuth




class TwitterUtility {
    
    typealias ErrorCompletion = (Error?) -> Void
    
    
    var oauthSwift:OAuthSwift?
    let consumerKey = "m9VCFFsoERuNegQQygfBRXIuB"
    let consumerSecret = "e3j6KgdXJIdudqcfa3K53rxmfuimQodmquTOdKNR0AHCyFL9kq"
    let followURL = "https://api.twitter.com/1.1/friendships/create.json"
    
    init ()
    {
        
    }
    
    
    
    func linkTwitterIn(viewController:UIViewController, completion:@escaping ErrorCompletion){
        
        let oauthswift = OAuth1Swift(
            consumerKey:    "m9VCFFsoERuNegQQygfBRXIuB",
            consumerSecret: "e3j6KgdXJIdudqcfa3K53rxmfuimQodmquTOdKNR0AHCyFL9kq",
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        self.oauthSwift = oauthswift
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: self.oauthSwift!)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "qnect://")!,
            success: { credential, response, parameters in
              
                
                
                let token = credential.oauthToken
                let tokenSecret = credential.oauthTokenSecret
                var screenName = ""
            
                for object in parameters {
                    if object.key == "screen_name" {
                        screenName = object.value as! String
                    }
                    
                }
                
                
                self.doesUserExist(screenName: screenName, completion: { (userExists) in
                    if userExists {
                        let error = NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey:"This Twitter account is already linked with another user"])
                        completion(error)
                        
                    }else {
                        let ref = FIRDatabase.database().reference()
                        let usersRef = ref.child("users")
                        
                        let currentUser = FIRAuth.auth()?.currentUser!
                        let uidRef = usersRef.child((currentUser?.uid)!)
                        let accountsRef = uidRef.child("accounts")
                        let twitterRef = accountsRef.child("twitter")
                        
                        twitterRef.keepSynced(true)
                        twitterRef.setValue(["screenName":screenName,"token":token, "tokenSecret":tokenSecret])
                        
                    }
                })
                
                
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    private func doesUserExist(screenName:String, completion:@escaping (Bool) ->Void)
    {
        let ref = FIRDatabase.database().reference()
        let twitterRef = ref.child("twitter")
        let screenNameRef = twitterRef.child(screenName)
        
        
        screenNameRef.keepSynced(true)
        twitterRef.keepSynced(true)
        screenNameRef.observeSingleEvent(of:.value, with: { (snapshot) in
            
            if snapshot.exists() {
                completion(true)
            }else {
                twitterRef.keepSynced(true)
                twitterRef.setValue([screenName:FIRAuth.auth()?.currentUser?.email])
                completion(false)
            }
        })
    }
    
    func unlinkTwitter(completion: @escaping (Void) -> Void)
    {
        
        User.currentUser { (user) in
            
            
            let ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users")
            
            let currentUser = FIRAuth.auth()?.currentUser!
            let uidRef = usersRef.child((currentUser?.uid)!)
            let accountsRef = uidRef.child("accounts")
            let twitterAccountRef = accountsRef.child("twitter")
            
            twitterAccountRef.keepSynced(true)
            twitterAccountRef.removeValue()
            
        
            
            let twitterRef = ref.child("twitter")
            let screenNameRef = twitterRef.child((user.accounts["twitter"]?.screenName)!)
            
            
            screenNameRef.keepSynced(true)
            screenNameRef.removeValue()
            

            
            user.accounts.removeValue(forKey: "twitter")
            
            
            completion()
            
        }
    }
    
    
    func isUserLinkedWithTwitter(completion:@escaping (Bool?) -> Void)
    {
     
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let currentUser = FIRAuth.auth()?.currentUser!
        let uidRef = usersRef.child((currentUser?.uid)!)
        let accountsRef = uidRef.child("accounts")
        let twitterRef = accountsRef.child("twitter")
        twitterRef.keepSynced(true)
        
        twitterRef.observeSingleEvent(of:.value, with: { (snapshot) in
            if snapshot.exists() {
                completion(true)
            }else {
                completion(false)
            }
        })

    }
    
    
    func followUserWith(screenName:String, completion:@escaping ErrorCompletion) {
        
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("users")
        
        let currentUser = FIRAuth.auth()?.currentUser!
        let uidRef = usersRef.child((currentUser?.uid)!)
        let accountsRef = uidRef.child("accounts")
        let twitterRef = accountsRef.child("twitter")
        twitterRef.keepSynced(true)
        
        twitterRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! [String: AnyObject]
            
            let token = snapshotValue["token"] as! String
            let tokenSecret = snapshotValue["tokenSecret"] as! String
            
            let client = OAuthSwiftClient(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, oauthToken: token, oauthTokenSecret: tokenSecret, version: OAuthSwiftCredential.Version.oauth1)
            
            _ = client.post(self.followURL, parameters: ["screen_name":screenName],success: { (response) in
                let json = try? response.jsonObject()
                print(json!)
                
                completion(nil)
            }, failure: { (error) in
                completion(error)
            })
        })
    }
    
    
    static func accessTwitter(){
        let accountStore = ACAccountStore()
        let type = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccounts(with: type!, options: nil) { (bool, error) in
            if error != nil {
                print(error!)
                
            }else {
                    let accounts = accountStore.accounts as! [ACAccount]
                for account in accounts {
                    if account.credential != nil {
                        print(account.credential)
                    }
                }
            }
        }
        
    }
}

