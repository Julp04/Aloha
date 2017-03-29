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

    
    var cornerRadius: CGFloat = 50.0
    var borderColor: UIColor = .white
    
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
    }

}
