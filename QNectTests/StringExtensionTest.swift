//
//  QNectTests.swift
//  QNectTests
//
//  Created by Julian Panucci on 10/21/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import XCTest
@testable import QNect

class StringExtensionTest: XCTestCase {
    

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAsDateWorks() {
        let actualBirthdate = "10-09-1993".asDate()
        
        let calendar = Calendar.current
        let components = DateComponents(calendar: calendar, timeZone: nil, era: nil, year: 1993, month: 10, day: 09, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        let expectedDate = calendar.date(from: components)
        
        XCTAssertEqual(expectedDate, actualBirthdate)
    }
    
    func testIsValidEmailWorks() {
        var correctEmail = "julpanucci@gmail.com"
        XCTAssertTrue(correctEmail.isValidEmail)
        
        correctEmail = "julpanucci@qnect.org"
        XCTAssertTrue(correctEmail.isValidEmail)
        
        var incorrectEmail = "ajkajfkajfkajf"
        XCTAssertFalse(incorrectEmail.isValidEmail)
        
        incorrectEmail = "julpanucci@.com"
        XCTAssertFalse(incorrectEmail.isValidEmail)
        
        incorrectEmail = "jkjkajka.com"
        XCTAssertFalse(incorrectEmail.isValidEmail)
    }
    
    func testIsValidPasswordWorks() {
        let tooShort = "hey1"
        XCTAssertFalse(tooShort.isValidPassword)
        
        let noUppercase = "kajfkajfkajkfjak23"
        XCTAssertFalse(noUppercase.isValidPassword)
        
        let noLowercase = "FJAFJJFAJG1"
        XCTAssertFalse(noLowercase.isValidPassword)
        
        let tooLong = "thispasswordisDefinitelyTooLongButHasUppercaseAndLowercase"
        XCTAssertFalse(tooLong.isValidPassword)
        
        let perfect = "Julian34"
        XCTAssertTrue(perfect.isValidPassword)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
