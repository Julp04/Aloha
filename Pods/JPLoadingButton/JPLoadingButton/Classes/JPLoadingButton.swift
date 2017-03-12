import Foundation
import UIKit

let PINK = UIColor(red:0.992157, green: 0.215686, blue: 0.403922, alpha: 1)
let DARK_PINK = UIColor(red:0.798012, green: 0.171076, blue: 0.321758, alpha: 1)

@IBDesignable
open class JPLoadingButton : UIButton, UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    
    open var didEndFinishAnimation : (()->())? = nil

    let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    let shrinkCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    let unshrinkCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    var shrinkDuration:CFTimeInterval = 0.15
    var unshrinkDuration: CFTimeInterval = 0.1
   

    lazy var spinner: SpinnerLayer! = {
        let s = SpinnerLayer(frame: self.frame)
        self.layer.addSublayer(s)
        return s
    }()
    
    
    @IBInspectable open var shrinkSpeed:CGFloat = 0.15 {
        didSet {
            shrinkDuration = CFTimeInterval(shrinkSpeed)
        }
    }
    
    @IBInspectable open var unshrinkSpeed:CGFloat = 0.1 {
        didSet {
            unshrinkDuration = CFTimeInterval(unshrinkSpeed)
        }
    }

    
    
   @IBInspectable open var cornerRadius: CGFloat? = 20.0 {
        didSet {
            layer.cornerRadius = cornerRadius!
        }
    }

    @IBInspectable open var highlightedBackgroundColor: UIColor? = DARK_PINK {
        didSet {
            self.setBackgroundColor()
        }
    }
    @IBInspectable open var normalBackgroundColor: UIColor? = PINK {
        didSet {
            self.setBackgroundColor()
        }
    }
    
    @IBInspectable open var spinnerColor:UIColor? = UIColor.white {
        didSet {
            self.spinner.strokeColor = spinnerColor?.cgColor
        }
    }
    
    @IBInspectable open var spinnerWidth:CGFloat? = 1.0 {
        didSet {
            self.spinner.lineWidth = spinnerWidth!
        }
    }

    var cachedTitle: String?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    override open var isHighlighted: Bool {
        didSet {
            self.setBackgroundColor()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        self.setBackgroundColor()
    }

    func setBackgroundColor() {
        if (isHighlighted) {
            self.backgroundColor = highlightedBackgroundColor
        }
        else {
            self.backgroundColor = normalBackgroundColor
        }
    }

    open func startLoadingAnimation() {
        self.cachedTitle = title(for: UIControlState())
        self.setTitle("", for: UIControlState())
        self.shrink()
        self.isUserInteractionEnabled = false
       
        Timer.schedule(delay: shrinkDuration - 0.25) { timer in
            self.spinner.startAnimation()
        }
    }
    
    
    open func stopLoadingAnimation(title:String)
    {
        self.setTitle(title, for: UIControlState())
        self.cachedTitle = title
        self.unshrink()
        Timer.schedule(delay: 0.12) { timer in
            self.returnToOriginalState()
            self.spinner.stopAnimation()
        }
    }
    
    open func stopLoadingAnimation()
    {
        self.unshrink()
        Timer.schedule(delay: 0.12) { timer in
            self.returnToOriginalState()
            self.spinner.stopAnimation()
        }
    }

    open func startFinishAnimation(_ delay: TimeInterval, completion:(()->())?) {
        Timer.schedule(delay: delay) { timer in
            self.didEndFinishAnimation = completion
            self.expand()
            self.spinner.stopAnimation()
        }
    }
    
    open func startFinishAnimation(completion:(() -> Void)?)
    {
        self.didEndFinishAnimation = completion
        self.expand()
        self.spinner.stopAnimation()
        
    }
    
    open func startFinishAnimationWith(currentVC:UIViewController, viewController:UIViewController)
    {
        
        didEndFinishAnimation = {
            
            
            viewController.transitioningDelegate = self
            currentVC.present(viewController, animated: true, completion: nil)
            
            
        }
        
        self.expand()
        self.spinner.stopAnimation()
        
        
    }

    open func animate(_ duration: TimeInterval, completion:(()->())?) {
        startLoadingAnimation()
        startFinishAnimation(duration, completion: completion)
    }

     public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        let a = anim as! CABasicAnimation
        if a.keyPath == "transform.scale" {
            didEndFinishAnimation?()
            Timer.schedule(delay: 1) { timer in
                self.returnToOriginalState()
            }
        }
    }
    
    func returnToOriginalState() {
        self.layer.removeAllAnimations()
        self.setTitle(self.cachedTitle, for: UIControlState())
        self.isUserInteractionEnabled = true
    }
    
    func shrink() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = frame.width
        shrinkAnim.toValue = frame.height
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = kCAFillModeForwards
        shrinkAnim.isRemovedOnCompletion = false
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
    func unshrink()
    {
        let unshrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        unshrinkAnim.fromValue = frame.height
        unshrinkAnim.toValue = frame.width
        unshrinkAnim.duration = unshrinkDuration
        unshrinkAnim.timingFunction = unshrinkCurve
        unshrinkAnim.fillMode = kCAFillModeForwards
        unshrinkAnim.isRemovedOnCompletion = false
        layer.add(unshrinkAnim, forKey: unshrinkAnim.keyPath)

    }
    
    func expand() {
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 1.0
        expandAnim.toValue = 26.0
        expandAnim.timingFunction = expandCurve
        expandAnim.duration = 0.3
        expandAnim.delegate = self
        expandAnim.fillMode = kCAFillModeForwards
        expandAnim.isRemovedOnCompletion = false
        layer.add(expandAnim, forKey: expandAnim.keyPath)
        
    }
    
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JPFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
}
