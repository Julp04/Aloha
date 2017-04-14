//
//  Date+Extension.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation

extension Date {
    var age: String {
        get {
            let now = Date()
            let birthday: Date = self
            let calendar = Calendar.current
            
            let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
            return String(ageComponents.year!)
        }
    }
    
    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
}
