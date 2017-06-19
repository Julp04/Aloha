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
    
    var date: Date
    var data: String
    

    init(data: String) {
        self.data = data;
        self.date = Date();
    }
    
    
}
