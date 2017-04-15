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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
