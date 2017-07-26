//
//  String+Extension.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation

extension String {
    
    var isValidEmail: Bool {
        get {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: self)
        }
    }
    
    /// A valid password must be between 6 to 15 characters and have one upper case and lowercase letter and a number
    var isValidPassword: Bool {
        get {
            let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,15}$"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
            return passwordTest.evaluate(with: self)
        }
    }
    
    func asDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }
    
    func isLetter() -> Bool {
        let alphaCharacters = NSCharacterSet.letters.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: alphaCharacters) == nil
    }
    
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
    
    
    func checkForURL() -> String? {
        
        if self.contains("http://") || self.contains("https://") {
            return self
        }
        
        if let path = Bundle.main.path(forResource: "domains", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let domains = data.components(separatedBy: .newlines)
                
                for domain in domains {
                    if self.lowercased().contains(domain.lowercased()) && !self.contains(" ") {
                        return "http://" + self
                    }
                }
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}


