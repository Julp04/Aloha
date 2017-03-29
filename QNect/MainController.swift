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
import PTPopupWebView

class MainController: PageboyViewController, NavgationTransitionable, ModalTransitionDelegate  {
    
    /// Transiton delegate
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var tr_pushTransition: TRNavgationTransitionDelegate?

 
    //MARK: Properties
    //todo: This controller will become scanner controller and scanner controller will be a place holder
    var placeHolderViewController: UIViewController!
    var profileViewController: UINavigationController!
    var connectionsViewController: UINavigationController!
    
    var colorView: UIView!
    var toFromIndex: (Int, Int) = (0, 0)
    let kDismissString = "Dismiss"
    let kPinchVelocity = 8.0
    var scannedContact = 0
    var contactImage:UIImage?
    var showURLAlert = 0
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var message: String?
    var contact: User!
    var qrCodeFrameView = UIImageView()
    var scannerCanScan = true
    
    
    //MARK: Actions
    
    @IBAction func gesture(_ sender: AnyObject) {
        handleGesture(sender)
    }
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorView = UIView(frame: view.frame)
        view.insertSubview(colorView, at: 0)
        colorView.backgroundColor = .qnPurple
        colorView.alpha = 0.0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewControllerNav") as! UINavigationController
        connectionsViewController = storyboard.instantiateViewController(withIdentifier: "ConnectionsViewControllerNav") as! UINavigationController
        placeHolderViewController = storyboard.instantiateViewController(withIdentifier: "PlaceHolderViewController")
        placeHolderViewController.view.alpha = 0.0
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MainController.interactiveTransition(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        createCaptureSession()
        startCaptureSession()
        
        self.dataSource = self
        self.delegate = self
    }
    
    //MARK: Capture Session Functions
    
    func createCaptureSession()
    {
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
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
        }
    }
    
    func startCaptureSession()
    {
        captureSession?.startRunning()
    }
    
    func stopCaptureSession()
    {
        captureSession?.stopRunning()
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
    
  


    //MARK: Scanning Contact
    
    func handleScannedContact(_ metadataObj:AVMetadataMachineReadableCodeObject, barCodeObject:AVMetadataMachineReadableCodeObject)
    {
        self.stopCaptureSession()
        segueToContactViewController()
    }
    
    
    
    func centerForBarcodeObject(_ barCodeObject:AVMetadataMachineReadableCodeObject) -> CGPoint
    {
        let centerX = barCodeObject.bounds.origin.x + (barCodeObject.bounds.size.width / 2.0)
        let centerY = barCodeObject.bounds.origin.y + (barCodeObject.bounds.size.height / 2.0)
        let center = CGPoint(x: centerX, y: centerY)
        return center
    }
    
    //Pinch to zoom
    func handleGesture(_ sender: AnyObject)
    {
        let pinchVelocityDividerFactor = kPinchVelocity;
        
        
        if (sender.state == UIGestureRecognizerState.changed) {
            let pinch = sender as! UIPinchGestureRecognizer
            do {
                try captureDevice?.lockForConfiguration()
                
                let desiredZoomFactor = Double((captureDevice?.videoZoomFactor)!) + atan2(Double(pinch.velocity), pinchVelocityDividerFactor)
                
                captureDevice?.videoZoomFactor = max(1.0,min(CGFloat(desiredZoomFactor), (captureDevice?.activeFormat.videoMaxZoomFactor)!))
                
                captureDevice?.unlockForConfiguration()
            }catch let error as NSError {
                print(error)
            }
        }
    }
    
    
    
    //MARK: Segue
    
    func segueToContactViewController()
    {
        performSegue(withIdentifier: SegueIdentifiers.Contact, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.Contact {
            if let contactVC = (segue.destination as! UINavigationController).topViewController as? ContactViewController {
                contactVC.configureViewController(self.contact!)
            }
        }
    }
    

}

extension MainController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        
        guard scannerCanScan else {
            //If scannerCanScan is set to true we must be on a different page where we will not allow scanning
            return
        }
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            showURLAlert = 0
            return
        } else {
            
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode{
                if let contact = QnDecoder.decodeQRCode(metadataObj.stringValue) {
                    
                    self.contact = contact
                    
                    handleScannedContact(metadataObj, barCodeObject: barCodeObject)
                    
                }else if metadataObj.stringValue.contains(".com") {
                    
                    //Todo: Need to test different QRCodes and handle different strings
                    var url = ""
                    if !metadataObj.stringValue.contains("http"){
                        url = "http://\(metadataObj.stringValue)"
                    }else {url = metadataObj.stringValue}
                    
                    
                    let popupvc = PTPopupWebViewController()
                    popupvc.popupView.URL(string: url)
                    let closeButton = PTPopupWebViewButton(type: .custom).title("Close").foregroundColor(UIColor.qnBlue)
                    closeButton.handler({
                        self.startCaptureSession()
                        popupvc.close()
                    })
                    
                    let safariButton = PTPopupWebViewButton(type: .custom).backgroundColor(UIColor.qnBlue).foregroundColor(UIColor.white)
                    safariButton.title("Open in Safari")
                    safariButton.handler({
                        UIApplication.shared.openURL(URL(string: url)!)
                    })
                    
                    popupvc.popupView.addButton(safariButton)
                    popupvc.popupView.addButton(closeButton)
                    popupvc.show()
                    self.stopCaptureSession()
                }
                else {
                    let alert = UIAlertController(title: nil, message: metadataObj.stringValue, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: kDismissString, style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension MainController: PageboyViewControllerDelegate {
    // MARK: PageboyViewControllerDelegate
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAtIndex index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        //If we are scrolling then disable scanning
        scannerCanScan = false
        
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
        
        //If not on the scanner page then we do not allow scanning
        scannerCanScan = index != 1 ? false : true
        
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

extension MainController: PageboyViewControllerDataSource {
    //MARK: Pageboy Datasource
    
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // return array of view controllers
        return [profileViewController, placeHolderViewController, connectionsViewController]
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // set ScannerViewController as first controller you see at index 1. Which is in the middle
        return PageIndex.atIndex(index: 1)
    }
    
}


extension MainController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}



