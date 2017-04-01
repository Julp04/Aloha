//
//  GradientView.swift
//  Gradient
//
//  Created by Panucci, Julian R on 3/31/17.
//  Copyright © 2017 Panucci, Julian R. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    let gradientLayer = CAGradientLayer()
    var colors: [CGColor]? {
        didSet {
            gradientLayer.isHidden = false
            layoutSubviews()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            gradientLayer.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        if colors != nil {
            gradientLayer.frame = self.bounds
            gradientLayer.colors = colors
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.locations = [0, 0.7]
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
            
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
   
    
    override func draw(_ rect: CGRect) {
        
    
    }


}
