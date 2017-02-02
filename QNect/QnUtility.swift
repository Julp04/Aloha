//
//  QnUtility.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import Parse
import ParseTwitterUtils

class QnUtilitiy {
    
    
    
    class func linkTwitterUserInBackground(_ user:User, completion:@escaping ((NSError?) -> Void))
    {
        PFTwitterUtils.linkUser(user) { (success, error) -> Void in
            if error != nil {
                completion(error as NSError?)
            } else {
                user.twitterScreenName = PFTwitterUtils.twitter()?.screenName
                user.saveInBackground()
                completion(error as NSError?)
            }
        }
    }
    
    static func unlinkTwitterUser(_ completion: @escaping (NSError?) -> Void)
    {
        PFTwitterUtils.unlinkUser(inBackground: User.current()!, block: { (success, error) -> Void in
            if error != nil {
                completion(error as NSError?)
            } else {
                User.current()!.twitterScreenName = nil
                User.current()!.saveEventually()
                completion(error as NSError?)
            }
        })
        
    }
    
    
    static func followContactOnTwitter(_ contact:User, completion:((JSON?,String?,NSError?)->Void)?)
    {
        let url = URL(string: "https://api.twitter.com/1.1/friendships/create.json")
        let request = NSMutableURLRequest(url: url!)
        let screenName = "screen_name=\(contact.twitterScreenName!)"
        request.httpMethod = "POST"
        request.httpBody = screenName.data(using: String.Encoding.utf8, allowLossyConversion: true)
        PFTwitterUtils.twitter()!.sign(request)
        
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) { (response, data, error) -> Void in
            if error != nil {
                completion!(nil, nil, error as NSError?)
            } else{
                let json = JSON(data: data!, options: [], error: nil)
                let requestErrorMessage = json["errors"][0]["message"].string
                completion!(json, requestErrorMessage, nil)}
        }
    }
    
    static func saveConnection(_ contact:User, completion:@escaping ((NSError?) -> Void))
    {
        
        retrieveSavedConnectionsOffline { (savedConnections) in
            for connection in savedConnections {
                if connection.username! == contact.username! {
                    let error = NSError(domain: "error", code: 100, userInfo: [NSLocalizedDescriptionKey:"User has already been added"])
                    
                    completion(error)
                    return
                }
            }
            
            let query = User.query()
            query?.whereKey("username", equalTo: contact.username!)
            query?.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    let contact = objects?.first as! User
                    
                    let newActivity = PFObject(className: "Activity")
                    newActivity["ActivityType"] = "saveContact"
                    newActivity["fromUser"] = User.current()!
                    newActivity["toUser"] = contact
                    
                    newActivity.pinInBackground(block: { (success, error) in
                        if error != nil {
                            completion(error as NSError?)
                        }
                    })
                    newActivity.saveEventually({ (s, error) in
                        if error != nil {
                            completion(error as NSError?)
                        }
                    })
                    
                }
                completion(error as NSError?)
            })
            
        }
    }
    
    static func retrieveSavedConnectionsOffline(_ completion:@escaping ([User]) -> Void)
    {
        let query = PFQuery(className: "Activity")
        query.whereKey("fromUser", equalTo: User.current()!)
        query.whereKey("ActivityType", equalTo: "saveContact")
        query.includeKey("toUser")
        query.fromLocalDatastore()
        
        var savedConnections = [User]()
        query.findObjectsInBackground { ( objects, error) in
            if error == nil {
                let activities = objects!
                for activity in activities {
                    let connection = activity["toUser"] as! User
                    savedConnections.append(connection)
                }
                
                completion(savedConnections)
                
            }
        }
    }
    
    static func retrieveAddedUserConnectionsFromServer(_ completion:@escaping ([User]) -> Void)
    {
        let query = PFQuery(className: "Activity")
        query.whereKey("toUser", equalTo: User.current()!)
        query.whereKey("ActivityType", equalTo: "saveContact")
        query.includeKey("fromUser")
        
        var addedUserConnections = [User]()
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                let activites = objects!
                for activity in activites {
                    let connection = activity["fromUser"] as! User
                    addedUserConnections.append(connection)
                }
                completion(addedUserConnections)
            }
        }
    }
    
    
    static func retreiveSavedConnectionsFromServer(_ completion:@escaping ([User]) -> Void)
    {
        let query = PFQuery(className: "Activity")
        query.whereKey("fromUser", equalTo: User.current()!)
        query.whereKey("ActivityType", equalTo: "saveContact")
        query.includeKey("toUser")
        
        var savedConnections = [User]()
        query.findObjectsInBackground { ( objects, error) in
            if error == nil {
                let activities = objects!
                for activity in activities {
                    let contact = activity["toUser"] as! User
                    savedConnections.append(contact)
                    
                }
                
                completion(savedConnections)
                PFObject.pinAll(inBackground: activities)
                
            }
        }
    }
    
    
    static func removeSavedConnection(_ connection:User, completion:@escaping (NSError?) -> Void)
    {
        let query = PFQuery(className: "Activity")
        query.whereKey("fromUser", equalTo: User.current()!)
        query.whereKey("toUser", equalTo: connection)
        query.whereKey("ActivityType", equalTo: "saveContact")
        query.includeKey("toUser")
        query.fromLocalDatastore()
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                PFObject.unpinAll(inBackground: objects!)
                PFObject.deleteAll(inBackground: objects)
                
                completion(error as NSError?)
            }else {
                completion(error as NSError?)
            }
            
        }
    }
    
    static func retrieveUserByUsername(_ username:String, completion:@escaping (User) -> Void)
    {
        let userQuery = User.query()
        userQuery?.whereKey("username", equalTo: username)
        userQuery?.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                let user = objects?.first as! User
                completion(user)
            }
        })
        
        
    }
    
    
    
    
    
    static func retrieveContactProfileImageData(_ contact:User, completion:@escaping ((Data) -> Void))
    {
        let query = User.query()
        query?.whereKey("username", equalTo: (contact.username)!)
        query?.getFirstObjectInBackground(block: { (object, error) -> Void in
            if error == nil {
                let addedUser = object as! User
                let imageFile = addedUser.object(forKey: "profileImage") as! PFFile
                imageFile.getDataInBackground { (data, error) -> Void in
                    if error == nil {
                        completion(data!)
                    }
                }
            } else {
                print(error)
            }
        })
    }
}
