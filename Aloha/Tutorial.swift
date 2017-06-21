//
//  Tutorial.swift
//  Aloha
//
//  Created by Panucci, Julian R on 6/21/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import EasyTipView


extension EasyTipView {
    func showTip(animated:Bool, for view: UIView, within superview: UIView?) {
        if Tutorial.isOn {
            self.show(animated: animated, forView: view, withinSuperview: superview)
        }
    }
}

struct Tutorial {
    
    public static var isOn: Bool {
        get {
            return false
        }
    }
    
    static let revealQRCode = "revealQRCode"
    static let qrCodeShown = "qrCodeShown"
    static let addContact = "addContact"
    static let addTwitterProfile = "addTwitterProfile"
    static let followTwitterUser = "followTwitterUser"
    static let holdTwitterButton = "holdTwitterButton"
    static let addProfilePicture = "addProfilePicture"
    static let noAddedConnections = "noAddedConnections"
}
