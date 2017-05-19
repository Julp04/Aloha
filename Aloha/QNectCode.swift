//
//  QNectCode.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import UIKit

class QNectCode
{
    
    //MARK: Properties
    
    static let kCodeLength = 250
    
    var size = CGSize(width: kCodeLength, height: kCodeLength)
    let scale = 3 * UIScreen.main.scale
    var color = UIColor.main
    var backgroundColor = UIColor.white
    var data: Data?
    
    fileprivate var ciColor: CIColor{
        return CIColor(color: color)
    }
    var backgroundCIColor:CIColor{
        return CIColor(color: backgroundColor)
    }
    
    var image:UIImage{
        
        let cgContext = CIContext(options: nil)
        let cgImage = cgContext.createCGImage(ciImage, from: ciImage.extent)
        
        UIGraphicsBeginImageContext(CGSize(width: ciImage.extent.size.width * scale, height: ciImage.extent.size.width * scale));
        let context = UIGraphicsGetCurrentContext()
        
        context!.interpolationQuality = CGInterpolationQuality.none;
        context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return image!
    }
    
    fileprivate var ciImage:CIImage{
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Color code and background
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(ciColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundCIColor, forKey: "inputColor1")
        
        let image = colorFilter.outputImage!
        
        return image
    }
    
    
    init(message:String)
    {
        data = message.data(using: String.Encoding.utf8, allowLossyConversion: false)
    }
    
    
    
    
}
