//
//  MainController.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/28/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import Pageboy
import AVFoundation
import TransitionTreasury
import TransitionAnimation

class MainController: PageboyViewController, PageboyViewControllerDelegate, PageboyViewControllerDataSource,  NavgationTransitionable, ModalTransitionDelegate, UIGestureRecognizerDelegate  {
    /// Transiton delegate
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var tr_pushTransition: TRNavgationTransitionDelegate?

 
    var scannerViewController: ScannerViewController!
    var profileViewController: UINavigationController!
    var connectionsViewController: UINavigationController!
    
    
    var colorView: UIView!
    
    
    var toFromIndex: (Int, Int) = (0, 0)
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorView = GradientView(frame: view.frame)
        view.insertSubview(colorView, at: 0)
        colorView.backgroundColor = .qnPurple
        colorView.alpha = 0.0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        scannerViewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewControllerNav") as! UINavigationController
        connectionsViewController = storyboard.instantiateViewController(withIdentifier: "ConnectionsViewControllerNav") as! UINavigationController
        

        self.dataSource = self
        self.delegate = self
        
        scannerViewController.view.alpha = 0.0
        
        var error:NSError?
        let input:AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error != nil{
            print("\(error?.localizedDescription)")
        } else {
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as! AVCaptureInput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            
            captureSession?.startRunning()
        }
        
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MainController.interactiveTransition(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        

        
    }
    
    func interactiveTransition(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard sender.velocity(in: view).y > 0 else {
                break
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeController")  as! QnectCodeViewController
            vc.modalDelegate = self
            
            tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: sender, dismiss: vc.dismissGestureRecognizer), completion: {
            })
        default: break
        }
    }
    
    
    func modalViewControllerDismiss(interactive: Bool, callbackData data: Any?) {
        tr_dismissViewController(interactive, completion: nil)
    }
    
    //MARK: Pageboy Datasource

    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // return array of view controllers
        return [profileViewController, scannerViewController, connectionsViewController]
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // set ScannerViewController as first controller you see at index 1. Which is in the middle
        return PageIndex.atIndex(index: 1)
    }

    
    // MARK: PageboyViewControllerDelegate
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAtIndex index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
     
        toFromIndex = calculateToFromIndexTuple(direction: direction, index: index)
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPosition position: CGPoint,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        updateColorViewAlpha(position: position)
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAtIndex index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        
        
    }
    
    
    func calculateToFromIndexTuple(direction: PageboyViewController.NavigationDirection, index: Int) -> (Int, Int)
    {
        let toIndex = index
        var fromIndex = 0
        
        if direction == .reverse && index == 0 {
            fromIndex = 1
        }
        
        if direction == .forward && index == 1 {
            fromIndex = 0
        }
        
        if direction == .reverse && index == 1 {
            fromIndex = 2
        }
        
        if direction == .forward && index == 2 {
            fromIndex = 1
        }
        
        return(toIndex, fromIndex)
    }
    
    func updateColorViewAlpha(position: CGPoint) {
        switch toFromIndex {
        case (1, 0), (0, 1):
            colorView.backgroundColor = .qnPurple
            colorView.alpha = 1 - position.x
        case (2, 1), (1, 2):
            colorView.backgroundColor = .qnGreen
            colorView.alpha = position.x - 1
        default:
            break
        }
    }

    

}
