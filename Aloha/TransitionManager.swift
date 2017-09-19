//
//  SlideAnimator.swift
//  Transition
//
//  Created by Panucci, Julian R on 3/26/17.
//  Copyright © 2017 Panucci, Julian R. All rights reserved.
//

import UIKit

class TransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var interactionInProgress = false
    var shouldCompleteTransition = false
    var presenting = true
    
    var isEnabled = false
    
    var segueIdentifier: String
    
    init(segueIdentifier: String) {
        self.segueIdentifier = segueIdentifier
    }
    
    var gesture: UIPanGestureRecognizer!
    var sourceViewController: UIViewController! {
        didSet {
            self.gesture = UIPanGestureRecognizer()
            self.gesture.addTarget(self, action: #selector(TransitionManager.handlePan(_:)))
            self.sourceViewController.view.addGestureRecognizer(gesture)
        }
    }
    
    var gesture2: UIPanGestureRecognizer!
    var presentedViewController: UIViewController! {
        didSet {
            self.gesture2 = UIPanGestureRecognizer()
            self.gesture2.addTarget(self, action: #selector(TransitionManager.handlePan(_:)))
            self.presentedViewController.view.addGestureRecognizer(gesture2)
        }
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        let container = transitionContext.containerView
        
        let screenUp = CGAffineTransform(translationX: 0, y: -container.frame.height)
        let screenDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        let duration = transitionDuration(using: transitionContext)
        
        if presenting {
        
            toView.transform = screenUp
            toView.alpha = 0.0
            
            UIView.animate(withDuration: duration, animations: {
                
                if let fromView = self.sourceViewController as? MainController {
                
                    fromView.colorView.colors = [UIColor.alohaYellow.cgColor, UIColor.alohaOrange.cgColor,]
                    fromView.colorView.alpha = 1.0
                    fromView.codeButton.layer.transform = CATransform3DMakeScale(0.0001, 0.0001, 1)
                }
                
                toView.transform = .identity
                toView.alpha = 1.0
                
            }) { (success) in
                
                if(transitionContext.transitionWasCancelled){
                    
                    transitionContext.completeTransition(false)
                    UIApplication.shared.keyWindow?.addSubview(fromView)
                    
                }else {
                    transitionContext.completeTransition(true)
                    UIApplication.shared.keyWindow?.addSubview(toView)
                    UIApplication.shared.keyWindow?.insertSubview(fromView, at: 0)
                }
            }
        }else {

            let snapshotView = fromView.snapshotView(afterScreenUpdates: false)
            snapshotView?.frame = fromView.frame
            container.addSubview(snapshotView!)
            
        
            UIView.animate(withDuration: duration, animations: {
                
                if let fromView = self.sourceViewController as? MainController {
                    fromView.colorView.alpha = 0.0
                    fromView.codeButton.alpha = 1.0
                    fromView.codeButton.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1)
                    
                }
                
                snapshotView?.transform = screenUp
                snapshotView?.layer.cornerRadius = 20.0
                snapshotView?.alpha = 0.0
            }) { (success) in
                if(transitionContext.transitionWasCancelled){
                    
                    transitionContext.completeTransition(false)
                    UIApplication.shared.keyWindow?.addSubview(fromView)
                }
                else {
                    transitionContext.completeTransition(true)
                    UIApplication.shared.keyWindow?.addSubview(toView)
                    
                }
            }

        }
    }
    
    private func presentView(_ toView: UIView) {
        
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        guard isEnabled else {
            return
        }
        
        let view2 = sender.view!.superview!
        
        if sender == gesture {
            let progress = sender.translation(in: view2).y / view2.frame.size.height + 0.1
            let velocity = sender.velocity(in: view2).y
            
            let offsetY: CGFloat = sender.translation(in: view2).y
            var percent = offsetY / (view2.bounds.size.height)
            percent = min(1.0, max(0, percent))
            
            switch sender.state {
            case .began:
                interactionInProgress = true
                sourceViewController.performSegue(withIdentifier: segueIdentifier, sender: self)
            case .changed:
                shouldCompleteTransition =  progress > 0.5
                update(progress)
            case .ended:
                interactionInProgress = false
                if shouldCompleteTransition {
                    finish()
                }else {
                    cancel()
                }
            default:
                break
            }
        }else {
            
            let progress = sender.translation(in: view2).y / -view2.frame.size.height
            let velocity = -sender.velocity(in: view2).y
            
            let offsetY: CGFloat = sender.translation(in: view2).y
            var percent = offsetY / (view2.bounds.size.height)
            percent = min(1.0, max(0, percent))
            
            print(progress)
            
            switch sender.state {
            case .began:
                interactionInProgress = true
                sourceViewController.dismiss(animated: true, completion: nil)
            case .changed:
                shouldCompleteTransition =  progress > 0.3
                update(progress)
            case .ended:
                interactionInProgress = false
                if shouldCompleteTransition {
                    finish()
                }else {
                    cancel()
                }
            default:
                break
            }
        }

        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactionInProgress ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionInProgress ? self: nil
    }
    
    

}
