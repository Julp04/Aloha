//
//  QnEncoder.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import AES256CBC



class QnEncoder {
    
    var user: User
    var qnString = "qn:"

    init(user:User)
    {
        self.user = user
    }

    func encodeUserInfo() -> String
    {
        
        let userProperties = [user.username, user.firstName, user.lastName, user.personalEmail, user.phone, user.uid, user.email, user.birthdate, user.location]
        
        for property in userProperties {
            if let property = property {
                qnString += "\(property):"
            } else {
                qnString += ":"
            }
        }
    
        // get AES-256 CBC encrypted string
        
        let encryptedString = AES256CBC.encryptString(qnString, password: Encyrptor.password.rawValue)!
        
        // decrypt AES-256 CBC encrypted string
        
        return encryptedString
    }

}
