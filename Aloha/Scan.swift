//
//  Scan.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/23/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation


enum ScanType  {
    case contact
    case url
    case message
}

struct Scan {
    
    var type: ScanType
    var date: Date
    var url: String?
    var contact: User?
    var message: String?
    
    private init(type: ScanType) {
        self.type = type
        self.date = Date()
        
    }
    
    init(url: String) {
        let type = ScanType.url
        self.init(type: type)
        self.url = url
    }
    
    init(contact: User) {
        let type = ScanType.contact
        self.init(type: type)
        self.contact = contact
    }
    
    init(message: String) {
        let type = ScanType.message
        self.init(type: type)
        self.message = message
    }
    
    
    
}
