//
//  Constants.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

struct ViewControllerIdentifier {
    static let Scanner = "ScannerNavController"
    static let QNectCode = "CodeNavController"
    static let Connections = "ConnectionsNavController"
    static let Containter = "ContainerViewController"
    static let Login = "LoginNavController"
}

struct UserInfo
{
    static let testUser = UserInfo()
    
    init() {
        firstName = "Test"
        lastName = "User"
        userName = "testuser"
        email = "test@g.com"
        password = "julian"
    }
    
    var firstName:String? = nil
    var lastName:String? = nil
    var userName:String? = nil
    var email:String? = nil
    var password:String? = nil
}

