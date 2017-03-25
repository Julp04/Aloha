//
//  ScannerViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import MessageUI
import ReachabilitySwift
import FCAlertView
import RKDropdownAlert
import PTPopupWebView

import TransitionTreasury
import TransitionAnimation





class ScannerViewController: UIViewController, SFSafariViewControllerDelegate, UIWebViewDelegate, NavgationTransitionable, ModalTransitionDelegate {
    
    //MARK: Properties
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    let kDismissString = "Dismiss"
    let kPinchVelocity = 8.0
    var scannedContact = 0
    var contactImage:UIImage?
    var showURLAlert = 0
    
    
    //MARK: Actions
    
    @IBAction func gesture(_ sender: AnyObject) {
        handleGesture(sender)
    }
    
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var message:String?
    var contact:User?
    var qrCodeFrameView = UIImageView()
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        createCaptureSession()
        
        // Do any additional setup after loading the view.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ScannerViewController.interactiveTransition(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCaptureSession()
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
                print("Present finished")
            })
        default: break
        }
    }
    

    func modalViewControllerDismiss(interactive: Bool, callbackData data: Any?) {
        tr_dismissViewController(interactive, completion: nil)
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
            view.layer.addSublayer(videoPreviewLayer!)
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
    
    //MARK: AVFoundation Delegate Methods
    
    /**
     Scanning for QRCode when recognized segues to Contact View Controller
     
     - parameter captureOutput:   not used
     - parameter metadataObjects: data of QRCode
     - parameter connection:      specific av capture connection
     */
    
    
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

extension ScannerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
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



