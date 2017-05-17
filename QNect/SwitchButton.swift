//
//  MyButton.swift
//  CustomButton
//
//  Created by Panucci, Julian R on 3/22/17.
//  Copyright © 2017 Panucci, Julian R. All rights reserved.
//

import UIKit

@IBDesignable
class SwitchButton: UIView {
    
    
    //MARK:Constants
    let kLabelHeight: CGFloat = 42.0
    let kLabelFontSizeSmall: CGFloat = 16.0
    let kLabelFontSizeLarge: CGFloat = 22.0
    

    //MARK: Inspectables
    @IBInspectable var cornerRadius: CGFloat = 20.0
    @IBInspectable var shadow: CGFloat = 0.0
    @IBInspectable open var duration: Double = 0.5
    @IBInspectable var onTintColor: UIColor = .blue
    @IBInspectable var isOn = false
    
    private var shortDescriptionLabel: UILabel?
    private var imageView: UIImageView?
    var shortText: String? {
        didSet {
            shortDescriptionLabel?.text = shortText
        }
    }
    
    var labelColor: UIColor = .white {
        didSet {
            shortDescriptionLabel?.textColor = labelColor
        }
    }
    var imageColor: UIColor = .white {
        didSet {
            imageView?.tintColor = imageColor
        }
    }
    
    var offColor: UIColor = .black
    
    fileprivate var shape: CAShapeLayer! = CAShapeLayer()
    
    private var rectShape = CAShapeLayer()
    private var startShape: CGPath!
    private var endShape: CGPath!
    private var button: UIButton!
    private var image: UIImage?

    
    open var animationDidStartClosure = {(onAnimation: Bool) -> Void in }
    open var animationDidStopClosure  = {(onAnimation: Bool, finished: Bool) -> Void in }
    open var onClick = { () -> Void in }
    open var isEnabled: Bool = true
    

   
    init(frame: CGRect, offColor: UIColor, onColor: UIColor, image: UIImage, shortText: String, isOn: Bool) {
        super.init(frame: frame)

        self.image = image.withRenderingMode(.alwaysTemplate)
        self.onTintColor = onColor
        self.offColor = offColor
        
        //Add image view and label
        let labelWidth = 0.575 * frame.width
        let imageSize = 0.25 * frame.width
        
        let imageY = (frame.height - imageSize) / 2
        let imageX: CGFloat = 8.0
        
        let labelX = labelWidth - imageSize + 10
        
        imageView = UIImageView(frame: CGRect(x: imageX, y: imageY, width: imageSize, height: imageSize))
            imageView?.image = self.image
        imageView?.contentMode = .scaleAspectFit
        
        shortDescriptionLabel = UILabel(frame: CGRect(x: labelX, y: (imageView?.center.y)! - kLabelHeight / 2.0, width: labelWidth, height: kLabelHeight))
        
        
        shortDescriptionLabel?.font = shortText.characters.count > 7 ? UIFont(name: "Futura", size: kLabelFontSizeSmall) : UIFont(name: "Futura", size: kLabelFontSizeLarge)
        shortDescriptionLabel?.numberOfLines = shortText.contains(" ") ? 0 : 1
        shortDescriptionLabel?.lineBreakMode = .byWordWrapping
        shortDescriptionLabel?.adjustsFontSizeToFitWidth = true
        shortDescriptionLabel?.text = shortText
        shortDescriptionLabel?.textAlignment = .center
        
        
        
        self.addSubview(imageView!)
        self.addSubview(shortDescriptionLabel!)
        
       
        
        self.backgroundColor = offColor
        layer.cornerRadius = cornerRadius
        
        self.isOn = isOn
       
        commonInit()
        
    }
    
    init(frame: CGRect ,color: UIColor) {
        super.init(frame: frame)
        onTintColor = color
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Helpers
    fileprivate func commonInit() {
        
        button = UIButton(frame: layer.bounds)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(SwitchButton.buttonAction), for: .touchUpInside)
        button.addTarget(self, action: #selector(SwitchButton.unShrink), for: .touchCancel)
        button.addTarget(self, action: #selector(SwitchButton.unShrink), for: .touchDragExit)
        button.addTarget(self, action: #selector(SwitchButton.shrink), for: .touchDown)
        self.addSubview(button)
        
        
        
        let rectBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        startShape = UIBezierPath(roundedRect: rectBounds, cornerRadius: 50).cgPath
        
        let height = layer.bounds.height * 3.0
        let width = height
        
        let x = height / -2.4 - 20
        let y = x
        
        let radius = CGFloat(height / 2.0)
        
        
        endShape = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: radius).cgPath
        
        rectShape.path = startShape
        rectShape.fillColor = onTintColor.cgColor
        rectShape.bounds = rectBounds
        rectShape.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        rectShape.cornerRadius = rectBounds.width / 2
        
        
        layer.insertSublayer(rectShape, at: 0)
        layer.masksToBounds = true
        
        if isOn {
            turnOn(animated: false)
        }else {
            turnOff(animated: false)
        }

    }
    
    
    
    // MARK: - Animations
    fileprivate func animateButton(toValue to: CGPath, animated: Bool = true) {
        
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.toValue               = to
        animation.fromValue = rectShape.path
        animation.timingFunction        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode              = kCAFillModeBoth
        animation.duration              = duration
        animation.delegate              = self
        
        if animated {
            rectShape.add(animation, forKey: animation.keyPath)
        }
        rectShape.path = to
    }
    
    func turnOn(animated: Bool = true) {
        //If button is off, turn it on
        animateButton(toValue: endShape, animated: animated)
        isOn = true

        UIView.animate(withDuration: 0.5, animations: { 
            self.imageView?.tintColor = self.offColor
            self.labelColor = self.offColor
        })
    }
    
    func turnOff(animated: Bool = true) {
        animateButton(toValue: startShape, animated: animated)
        isOn = false
        
        
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView?.tintColor = self.onTintColor
            self.labelColor = self.onTintColor
        })

    }
    
    func switchState() {
        isOn ? turnOff() : turnOn()
    }
    
    internal func buttonAction()
    {
        if isEnabled {
            onClick()
        }
        unShrink()
    }
    
    internal func shrink()
    {
        UIView.animate(withDuration: 0.5) { 
             self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    internal func unShrink() {
        UIView.animate(withDuration: 0.5) { 
            self.transform = CGAffineTransform.identity
        }
    }
}


extension SwitchButton: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        animationDidStartClosure(isOn)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationDidStopClosure(isOn, flag)
    }
}
