//
//  AlertUtility.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/9/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import RKDropdownAlert

class AlertUtility {
    
    
    
    static func showConnectionAlert()
    {
        RKDropdownAlert.title("No Internet Connection", message: "Please connect to the interwebs and try again", backgroundColor: UIColor.qnRed, textColor: UIColor.white)
    }
}
