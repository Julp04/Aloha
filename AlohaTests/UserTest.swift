//
//  UserTest.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import XCTest

@testable import Aloha
class UserTest: XCTestCase {
    
    let testUsername = "test123"
    let testFirstName = "Johnny"
    let testLastName = "Apples"
    let testEmail = "test@gmail.com"
    let testPhone = "4125551234"
    let testUID = "KAJHEBAJHNhjjahYTFGA"
    let testTwitter = "twitterTest"
    let testBirthdate = "10-09-1993"
    let testLocation = "Pittsburgh"
    
    var user: User!
    
    override func setUp() {
        super.setUp()
        
        user = User(username: testUsername, firstName: testFirstName, lastName: testLastName, personalEmail: testEmail, phone: testPhone, uid: testUID, email: testEmail, birthdate: testBirthdate, location: testLocation)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
