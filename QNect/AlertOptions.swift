//
//  AlertOptions.swift
//  QNect
//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import UIKit
import CRToast

class AlertOptions: UIView, UINavigationControllerDelegate
{
  
  
  class func statusBarOptionsWithMessage(_ message:String, withColor color:UIColor?) -> [AnyHashable: Any]!
  {
    var alertColor = UIColor.qnRedColor()
    if color != nil {
      alertColor = color!
    }
    
     let options = [kCRToastTextKey : message,
      kCRToastFontKey : UIFont(descriptor: UIFontDescriptor(), size: 15),
      kCRToastTextAlignmentKey : NSTextAlignment.center.rawValue,
      kCRToastBackgroundColorKey : alertColor, kCRToastNotificationTypeKey : CRToastType.statusBar.rawValue] as [String : Any]
    
    return options
  }
  
  class func navBarOptionsWithMessage(_ message:String, withColor color:UIColor?) -> [AnyHashable: Any]!
  {
    var alertColor = UIColor.qnRedColor()
    if color != nil {
      alertColor = color!
    }
    
    let navOptions = [kCRToastTextKey : message,
      kCRToastFontKey : UIFont(descriptor: UIFontDescriptor(), size: 15),
      kCRToastBackgroundColorKey : alertColor, kCRToastNotificationTypeKey : CRToastType.navigationBar.rawValue, kCRToastAnimationInDirectionKey : CRToastAnimationDirection.top.rawValue, kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.bottom.rawValue] as [String : Any]
    
    return navOptions
  }
  

}

public struct AlertMessages {
  static let Internet = "No Internet Connection"
  static let IncorrectParams = "Username or Password is incorrect"
  static let Email = "Missing Email"
  static let Password = "Password Must Be At Least 6 Characters"
  static let Username = "Missing Username"
}


