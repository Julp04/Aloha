//
//  QnEncoder.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import ParseTwitterUtils



class QnEncoder {
    
    var user:User!
    var qnString = "qn:"

    init(user:User)
    {
        self.user = user
    }

    func encodeSocialCode() -> String
    {
        
        let socialProperties = [user?.username, user?.firstName, user?.lastName, user?.socialEmail, user?.socialPhone, user?.twitterScreenName]
        
        for property in socialProperties {
            if let property = property {
                qnString += "\(property):"
            } else {
                qnString += ":"
            }
        }
        
        //encode once
        let data = (qnString as NSString).data(using: String.Encoding.utf8.rawValue)
        qnString = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: (0)))
        
        //encode twice
        let data2 = (qnString as NSString).data(using: String.Encoding.utf8.rawValue)
        qnString = data2!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: (0)))
        return qnString
    }

}
