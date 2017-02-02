//
//  ProfileImage.swift
//  QNect
//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import Foundation
import UIKit

class ProfileImage
{
    
    

    /**
    Creates a unique profile image for the user with their first and last initals.
    
    - parameter first: first name of user
    - parameter last:  last name of user
    
    - returns: the profile image
    */
    static func createProfileImage(_ first:String, last:String?) -> UIImage
    {
        let fontsize:CGFloat = 100
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let index = first.characters.index(first.startIndex, offsetBy: 0)
        
        UIRectFill(rect)
        let firstInitial = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        firstInitial.font = firstInitial.font.withSize(fontsize)
        firstInitial.textColor = UIColor.white
        if let last = last {
            firstInitial.text = "\(first[index])\(last[index])"
        }else {
            firstInitial.text = "\(first[index])"
        }
        firstInitial.textAlignment = .center
        firstInitial.sizeToFit()
        
        let view = UIView(frame: rect)
        
        view.backgroundColor = UIColor.qnPurpleColor()
        view.addSubview(firstInitial)
        firstInitial.center = (firstInitial.superview?.center)!
        
        let x =  NSLayoutConstraint(item: firstInitial, attribute: .centerX, relatedBy: .equal, toItem: firstInitial.superview, attribute:.centerX, multiplier: 1, constant: 0.0)
        let y = NSLayoutConstraint(item: firstInitial, attribute: .centerY, relatedBy: .equal, toItem: firstInitial.superview, attribute: .centerY, multiplier: 1, constant: 0.0)
        view.addConstraints([x,y])
        
        
        view.setNeedsUpdateConstraints()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        view
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func dataFromImage(_ image:UIImage) -> Data
    {
        return UIImageJPEGRepresentation(image, 0.5)!
    }
    
    class func imageFromData(_ data:Data) -> UIImage
    {
        return UIImage(data: data)!
    }
}
