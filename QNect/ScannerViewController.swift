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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, SFSafariViewControllerDelegate, UIWebViewDelegate {
    
    //MARK: Strings
    
    
    
    let kDismissString = "Dismiss"
    let kPinchVelocity = 8.0
    var scannedContact = 0
    var contactImage:UIImage?
    var showURLAlert = 0
    
    
    //If the item has just been recently picked or removed, then the background is selected so that the user knows which item they are currently working on
    // Set picked item back to false so other rows do not become selected when scrolling through list, because this method is called as rows reload.
    
    
    
    //MARK: Properties
    
    @IBAction func gesture(_ sender: AnyObject) {
        
        handleGesture(sender)
    }
    
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var message:String?
    var contact:User?
    var qrCodeFrameView = UIImageView()
    
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        createCaptureSession()
        
        
        
    }
    

    

  
    
    override func viewWillAppear(_ animated: Bool) {
        startCaptureSession()
    }
    
    //MARK: UI Methods
    
    
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
                    
                }else if metadataObj.stringValue.range(of: ".com") != nil {
  
                    var url = ""
                    if metadataObj.stringValue.range(of: "http") == nil {
                        url = "http://\(metadataObj.stringValue)"
                    }else {url = metadataObj.stringValue}
                    
                    if Defaults["AutomaticURLOpen"].bool == true {
                        
                        
                        
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
                            
                        
                        
                        
                    }else {
                        
                        if showURLAlert == 0 {
                        let alert = FCAlertView()
                        alert.addButton("Open webpage", withActionBlock: { 
                            UIApplication.shared.openURL(URL(string: url)!)
                        })
                            
                            alert.colorScheme = UIColor.qnBlue
                        
                            alert.showAlert(withTitle: url, withSubtitle: "", withCustomImage: nil, withDoneButtonTitle: "Close", andButtons: nil)
                            showURLAlert = 1
                        }
                    }
                
                }
                
                
                else {
                    let alert = UIAlertController(title: nil, message: metadataObj.stringValue, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: kDismissString, style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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



