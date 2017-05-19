//
//  JPLoadingButton+Extension.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation
import JPLoadingButton


extension JPLoadingButton {
    var enable:Bool {
        get {
            return self.isEnabled
        }
        set {
            self.isEnabled = newValue
            self.alpha  = newValue ? 1.0 : 0.5
        }
    }
}
