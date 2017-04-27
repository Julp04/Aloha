//
//  QnDecoder.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

struct QnDecoder
{
    fileprivate static var qnString = "qn:"
    
    static func decodeQRCode(_ message:String) -> User?
    {
        var decodedMessage = ""
        
        //decode once
        if var decodedData = Data(base64Encoded: message, options: Data.Base64DecodingOptions(rawValue: 0)) {

            var decodedString = String(data: decodedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            //decode twice
            decodedData = Data(base64Encoded: decodedString!, options: Data.Base64DecodingOptions(rawValue: 0))!
            decodedString = String(data: decodedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            decodedMessage = decodedString!
        }
        
        if (decodedMessage.range(of: qnString) != nil) {
            return decodeSocialCode(decodedMessage)
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
        let socialEmail = components[4] == "" ? nil: components[4]
        let socialPhone = components[5] == "" ? nil: components[5]
        let uid = components[6]
        let email = components[7]
        let birthdate = components[8] == "" ? nil: components[8]
        let location = components[9] == "" ? nil: components[9]
        
        

        
        let user = User(username: username, firstName: firstName, lastName: lastName, socialEmail: socialEmail, socialPhone: socialPhone, uid: uid, email: email, birthdate: birthdate, location: location)
        
        return user
        
    }
    
}
