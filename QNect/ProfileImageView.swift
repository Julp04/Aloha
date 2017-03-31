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


    var borderColor: UIColor = .white

    override func layoutSubviews() {
        layer.cornerRadius = self.bounds.size.width / 2.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
    }

}
