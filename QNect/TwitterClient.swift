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
import Social



extension DefaultsKeys {
    static let launchCount = DefaultsKey<Int>("launchCount")
    static let color = DefaultsKey<UIColor>("color")
}
class TwitterClient {
    
    typealias ErrorCompletion = (Error?) -> Void
    static let client = TwitterClient()
    var oauthSwift:OAuthSwift?
    let consumerKey = "m9VCFFsoERuNegQQygfBRXIuB"
    let consumerSecret = "e3j6KgdXJIdudqcfa3K53rxmfuimQodmquTOdKNR0AHCyFL9kq"
    let followURL = "https://api.twitter.com/1.1/friendships/create.json"
    
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
                        ref.keepSynced(true)
                    
                        
                        let currentUser = FIRAuth.auth()!.currentUser!
    
                        ref.child("users").child(currentUser.uid).child("accounts").child("twitter").setValue(["screenName": screenName, "token": token, "tokenSecret": tokenSecret])
                        ref.child("accounts").child("twitter").setValue(["screenName": screenName])
                        
                        completion(nil)
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

        ref.keepSynced(true)
      
        ref.child("accounts").child("twitter").child(screenName).observeSingleEvent(of:.value, with: { (snapshot) in
            
            if snapshot.exists() {
                completion(true)
            }else {
                completion(false)
            }
        })
    }
    
    func unlinkTwitter(completion: @escaping ErrorCompletion)
    {
    
        let ref = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()!.currentUser!
        
        ref.child("users").child(currentUser.uid).observeSingleEvent(of:.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            if let screenName = user.twitterAccount?.screenName {
            ref.child("accounts").child("twitter").child(screenName).removeValue(completionBlock: { (error, tw) in
                if error != nil {
                    completion(error)
                }else {
                    ref.child("users").child(currentUser.uid).child("twitterScreenName").removeValue(completionBlock: { (error, ref) in
                        if error != nil {
                            completion(error)
                        }
                    })
                }
            })
            }
        })
    }
    
    
    func isUserLinkedWithTwitter(completion:@escaping (Bool) -> Void)
    {
     
        let ref = FIRDatabase.database().reference()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        ref.child("users").child(currentUser.uid).child("accounts").child("twitter").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(true)
            }else {
                completion(false)
            }
        })
    }
    
    func followUserWith(screenName:String, completion:@escaping ErrorCompletion) {
        
        let ref = FIRDatabase.database().reference()
        ref.keepSynced(true)
        
        let currentUser = FIRAuth.auth()!.currentUser!
       
        ref.child("users").child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            
            guard let twitterAccount = user.twitterAccount else {
                return
            }
            let token = twitterAccount.token
            let tokenSecret = twitterAccount.tokenSecret
            
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
    
    
  
    
    //Functions used for access to Account Store Twitter Sign up method
//    
//    var accountStore: ACAccountStore
//    var accountType: ACAccountType
//    private var accounts: [ACAccount]?
//    var account:ACAccount?
    
    
    //    init ()
    //    {
    //        accountStore = ACAccountStore()
    //        accountType = accountStore.accountType(
    //            withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
    //    }

    
    
    //    func requestAccessToAccounts(completion:@escaping (Error?, Bool, [ACAccount]?) -> Void)
    //    {
    //        accountStore.requestAccessToAccounts(with: accountType, options: nil) { (success, error) in
    //            guard error == nil else {
    //                completion(error!, false, nil)
    //                return
    //            }
    //
    //            if success {
    //                let arrayOfAccounts = self.accountStore.accounts(with: self.accountType) as! [ACAccount]
    //                self.accounts = arrayOfAccounts
    //                completion(nil, true, self.accounts)
    //            }else {
    //                completion(nil, false, nil)
    //            }
    //        }
    //    }
    
    
    //    func linkTwitterAccount(account: ACAccount, completion: @escaping ErrorCompletion) {
    //
    //        let screenName = account.username!
    //        let token = account.credential
    //
    //
    //        self.doesUserExist(screenName: screenName) { (userExists) in
    //            guard userExists == false else {
    //                let error = NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey:"This Twitter account is already linked with another user"])
    //                completion(error)
    //                return
    //            }
    //            
    //            self.account = account
    //
    //        }
    //    }
    
    
    //Will be used if we link twitter accounts through phone account
    
    //    func follow(screenName: String, completion: @escaping ErrorCompletion)
    //    {
    //
    //        if let account = account {
    //            let requestURL = URL(string: followURL)
    //            let parameters = ["screen_name": screenName]
    //            let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: requestURL, parameters: parameters)
    //            postRequest?.account = account
    //
    //            postRequest?.perform(handler: { (data, response, error) in
    //                guard error == nil else {
    //                    completion(error!)
    //                    return
    //                }
    //
    //                let json = response?.description
    //                print(json!)
    //            })
    //        }
    //        
    //    }
    
//    static func accessTwitter(){
//        let accountStore = ACAccountStore()
//        let type = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
//        
//        accountStore.requestAccessToAccounts(with: type!, options: nil) { (bool, error) in
//            if error != nil {
//                print(error!)
//                
//            }else {
//                let accounts = accountStore.accounts as! [ACAccount]
//                for account in accounts {
//                    if account.credential != nil {
//                        print(account.credential)
//                    }
//                }
//            }
//        }
//        
//    }
    
    
}
