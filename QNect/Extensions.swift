//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import Foundation
import UIKit
import JPLoadingButton


public extension UIColor {
  
  convenience init(r: Int, g:Int , b:Int , a: Int) {
    self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a))
  }
    
   @nonobjc class var qnTeal: UIColor {
        get{
            return UIColor(r: 59, g: 199, b: 216, a: 1)
        }
    }
  
   @nonobjc class var qnGreenTeal: UIColor {
        get {
            return UIColor(r: 77, g: 197, b: 198, a: 1)
        }
    }
    
   @nonobjc class var qnBlue:UIColor {
        get {
            return UIColor(r: 54, g: 145, b: 204, a: 1)
        }
    }

   @nonobjc class var  qnPurple:UIColor {
        get {
            return UIColor(r: 61, g: 7, b: 105, a: 1)
        }
    }
    
   @nonobjc class var qnRed:UIColor {
        get {
            return UIColor(r: 175, g: 12, b: 12, a: 1)
        }
    }
  
   @nonobjc class var qnOrange:UIColor {
        get {
            return UIColor(r: 255, g: 128, b: 0, a: 1)
        }
    }
  
   @nonobjc class var qnGreen:UIColor{
        get {
            return UIColor(r: 44, g: 158, b: 43, a: 1)
        }
    }
  
   @nonobjc class var twitter:UIColor{
        get{
            return UIColor(r: 64, g: 153, b: 255, a: 1)
        }
    }
}

public extension String {
    
    //todo: check for thid
    //Terminating app due to uncaught exception 'InvalidPathValidation', reason: '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''

    var isValidEmail:Bool {
        get {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: self)
        }
    }
    
    /// A valid password must be between 6 to 15 characters and have one upper case and lowercase letter
    var isValidPassword:Bool {
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
}

public extension JPLoadingButton {
    var enable:Bool {
        get {
            return self.enable
        }
        set {
            self.isEnabled = newValue
            self.alpha  = newValue ? 1.0 : 0.5
        }
    }
}

public extension Date {
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


