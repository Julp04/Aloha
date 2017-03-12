//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import Foundation
import UIKit


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
            return UIColor(r: 47, g: 119, b: 230, a: 1)
        }
    }
    
   
    
}
