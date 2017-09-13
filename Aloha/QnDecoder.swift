//
//  QnDecoder.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import AES256CBC

public enum Encyrptor: String {
    
    case password = "********************"
    //CREATE OWN PASSWORD HERE
    
}

struct QnDecoder
{
    fileprivate static var qnString = "qn:"
    
    static func decodeQRCode(_ message:String) -> User?
    {
        
        guard let decryptedString = AES256CBC.decryptString(message, password: Encyrptor.password.rawValue) else {
            return nil
        }
        
        if(decryptedString.contains("qn:")) {
            return decodeSocialCode(decryptedString)
        }else {
            return nil
        }
       
    }

    fileprivate static func decodeSocialCode(_ message:String) -> User
    {
        let components = message.components(separatedBy: ":")
        
        
        let username = components[1]
        let firstName = components[2]
        let lastName = components[3]
        let personalEmail = components[4] == "" ? nil: components[4]
        let phone = components[5] == "" ? nil: components[5]
        let uid = components[6]
        let email = components[7]
        let birthdate = components[8] == "" ? nil: components[8]
        let location = components[9] == "" ? nil: components[9]
        
        

        
        let user = User(username: username, firstName: firstName, lastName: lastName, personalEmail: personalEmail, phone: phone, uid: uid, email: email, birthdate: birthdate, location: location)
        
        return user
        
    }
    
}
