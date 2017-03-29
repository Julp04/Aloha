//
//  ProfileImageView.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/29/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileImageView: UIImageView {

    
    @IBInspectable var cornerRadius: CGFloat = 0.0
  
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = self.cornerRadius
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }

}
