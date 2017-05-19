//
//  Scanner.swift
//  CartonInquiry
//
//  Created by Panucci, Julian R on 5/16/17.
//  Copyright © 2017 Panucci, Julian R. All rights reserved.
//

import UIKit
import AVFoundation

enum ScanningTypes {
    case qr
    case ean13
    case ean8
    case code128
}

class Scanner: NSObject {
    
    //MARK: - Constants
    
    let kPinchVelocity = 8.0
    
    private let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var view: UIView
    private var scannerTypes: [ScanningTypes]
    private var metaDataObjectTypes = [String]()
    var delegate: ScannerDelegate?
    
    var pinchGesture: UIPinchGestureRecognizer!
    
    var pinchToZoom = true {
        didSet {
            pinchGesture.isEnabled = pinchToZoom
        }
    }
    
    
    init(view: UIView, scanTypes: [ScanningTypes]) {
        self.view = view
        self.scannerTypes = scanTypes
        
        
        super.init()
        self.createCaptureSession()
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Scanner.handlePinch(_:)))
        self.view.addGestureRecognizer(pinchGesture)
        
    }
    
    private func createCaptureSession() {
        var error:NSError?
        let input:AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error != nil{
            print("\(String(describing: error?.localizedDescription))")
        } else {
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as! AVCaptureInput)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            
            for type in scannerTypes {
                metaDataObjectTypes.append(getScanType(type: type))
            }
            
            captureMetadataOutput.metadataObjectTypes = metaDataObjectTypes
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
        }
    }
    
    func startCaptureSession() {
        captureSession?.startRunning()
    }
    
    func stopCaptureSession() {
        captureSession?.stopRunning()
    }
    
    
    /// Pinch to zoom
    ///
    /// - Parameter sender: pinch gesture
    func handlePinch(_ sender: AnyObject) {
        let pinchVelocityDividerFactor = kPinchVelocity
        
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
    
    private func centerForBarcodeObject(_ barCodeObject:AVMetadataMachineReadableCodeObject) -> CGPoint {
        let centerX = barCodeObject.bounds.origin.x + (barCodeObject.bounds.size.width / 2.0)
        let centerY = barCodeObject.bounds.origin.y + (barCodeObject.bounds.size.height / 2.0)
        let center = CGPoint(x: centerX, y: centerY)
        return center
    }
    
    
    private func getScanType(type: ScanningTypes) -> String {
        switch type {
        case .qr:
            return AVMetadataObjectTypeQRCode
        case .ean8:
            return AVMetadataObjectTypeEAN8Code
        case .ean13:
            return AVMetadataObjectTypeEAN13Code
        case .code128:
            return AVMetadataObjectTypeCode128Code
        }
    }
}

extension Scanner: AVCaptureMetadataOutputObjectsDelegate {
   
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
       
        switch metadataObj.type {
        case AVMetadataObjectTypeQRCode:
            delegate?.scannerDidScan?(qrCode: metadataObj)
        case AVMetadataObjectTypeCode128Code:
            delegate?.code128DidScan?(code: metadataObj)
        default:
            break
        }
    
    }
}

//MARK: Gesture Delegate

extension Scanner: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}


@objc protocol ScannerDelegate {
    @objc optional func scannerDidScan(qrCode: AVMetadataMachineReadableCodeObject)
    
    @objc optional func code128DidScan(code: AVMetadataMachineReadableCodeObject)
}




