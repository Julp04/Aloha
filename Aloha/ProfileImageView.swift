//
//  ProfileImageView.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/29/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileImageView: UIView {

    var borderColor: UIColor = .white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    var imageView: UIImageView!
    var button: UIButton!
    open var onClick = { () -> Void in }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        imageView = UIImageView(frame: layer.bounds)
        button = UIButton(frame: layer.bounds)
        
        imageView.layer.cornerRadius = bounds.size.width / 2.0
        imageView.layer.masksToBounds = true
        
        button.layer.cornerRadius = bounds.size.width / 2.0
        button.addTarget(self, action: #selector(ProfileImageView.buttonClick), for: .touchUpInside)
        button.backgroundColor = .clear
        
        addSubview(button)
        addSubview(imageView)
        
        layer.cornerRadius = self.bounds.size.width / 2.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
    }
    
    @objc private func buttonClick() {
        onClick()
    }
}
