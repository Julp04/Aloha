//
//  AlohaUITests.swift
//  AlohaUITests
//
//  Created by Panucci, Julian R on 9/3/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import XCTest

class AlohaUITests: XCTestCase {
    
    
    func testExample() {
        // 1
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // 2
        let loginButton = app.buttons["login"]
        loginButton.tap()

        // 4
        snapshot("01UserEntries")
        // 5
        snapshot("02Suggestion")
    }
    
}
