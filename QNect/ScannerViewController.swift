//
//  ScannerViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import SafariServices
import CRToast
import MessageUI

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, SFSafariViewControllerDelegate, SphereMenuDelegate, MFMessageComposeViewControllerDelegate, UIWebViewDelegate {
    
    //MARK: Strings
    
    let kDismissString = "Dismiss"
    let kPinchVelocity = 8.0
    var scannedContact = 0
    var gotVideo = 0
    var contactImage:UIImage?
    var phoneAvailable = 0
    var twitterAvailable = 0
    var oldContactString = ""
    var oldVideoString = ""
    var playerPaused = 0
    var pinVideo = 0
    var showURLAlert = 0
    var showingContact = 0
    var lookingAtVideo = 0
    
    let youTubeVideoHTML = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player',{ width:'%0.0f', height:'%0.0f', videoId:'%@', playerVars:{playsinline:1}, events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>"
    
    
    //MARK: Properties
    
    @IBAction func gesture(_ sender: AnyObject) {
        
        handleGesture(sender)
    }
    
    let screenWidth = UIScreen.main.bounds.size.width
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var message:String?
    var contact:User?
    var qrCodeFrameView = UIImageView()
    var menu:SphereMenu?
    var images = [UIImage]()
    var containerView = UIView()
    var videoView:UIWebView?
    var indicator: UIActivityIndicatorView?
    
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        containerView.frame = CGRect(x: 40, y: 40, width: 200, height: 200)
        containerView.isHidden = true
        
        videoView = UIWebView(frame: CGRect(x: 40, y: 40, width: 350, height: 150))
        videoView?.allowsInlineMediaPlayback = true
        videoView?.mediaPlaybackRequiresUserAction = false
        videoView?.isHidden = true
        videoView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        videoView?.delegate = self
        
        indicator = UIActivityIndicatorView(frame: CGRect(x: 100, y: 75, width: 10, height: 10))
        indicator?.tintColor = UIColor.qnPurpleColor()
        videoView?.addSubview(indicator!)
        
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        createCaptureSession()
        
        
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        view.bringSubview(toFront: qrCodeFrameView)
        
        view.addSubview(containerView)
        view.bringSubview(toFront: containerView)
        
        self.view.addSubview(videoView!)
        view.bringSubview(toFront: videoView!)
        
        
        
    }
    
    func addContact()
    {
        let contactManager = ContactManager()
        if contactManager.addressBookStatus() == .denied {
            showCantAddContactAlert()
        } else if contactManager.addressBookStatus() == .authorized {
            contactManager.addContact(contact!, image:contactImage)
            showContactAddedToast()
        } else {
            contactManager.promptForAddressBookRequestAccess()
        }
    }
    
    func saveConnection()
    {
        QnUtilitiy.saveConnection(self.contact!) { (error) in
            if error == nil{
                self.sendPushNotification()
                CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("\(self.contact!.firstName) \(self.contact!.lastName) has been saved as a QNection!", withColor: UIColor.qnOrangeColor()), completionBlock: { () -> Void in
                })
                
                
                
            }else {
                CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage((error?.localizedDescription)!, withColor: UIColor.qnOrangeColor()), completionBlock: { () -> Void in
                })
            }
        }
    }
    
    func sendPushNotification()
    {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("username", equalTo: self.contact!.username!)
        print(self.contact!.username!)
        
        // Send push notification to query
        let push = PFPush()
        let data =   ["alert" : "\(User.current()!.firstName) \(User.current()!.lastName) has saved you as a connection!","name" : "\(User.current()!.firstName) \(User.current()!.lastName)", "username":User.current()!.username!, "category" : "cat"]
        push.setData(data)
        push.setQuery(pushQuery as! PFQuery<PFInstallation>?) // Set our Installation query
        push.sendInBackground(block: { (success, error) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    func followContactOnTwitter()
    {
        if User.current()!.twitterScreenName != nil{
            
            QnUtilitiy.followContactOnTwitter(self.contact!, completion: { (json, requestErrorMessage, error) in
                if error == nil {
                    print(json)
                    DispatchQueue.main.async(execute: {
                        if requestErrorMessage != nil {
                            CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage(requestErrorMessage!, withColor: UIColor.qnRedColor()), completionBlock: { () -> Void in
                            })
                            
                    
                        } else {
                            CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("You are now following \(self.contact!.twitterScreenName!)!", withColor: UIColor.twitterColor())) {}
                        }
                    })
                }else {
                    print(error)
                    DispatchQueue.main.async(execute: {
                        self.showInternetError()
                    })
                }
                
            })
            
        }else {
            showTwitterNotLinkedAlert()
        }
    }
    
    func sendMessage()
    {
        if let phoneNumber = contact?.socialPhone {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.recipients = ["\(phoneNumber)"]
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: false, completion: nil)
        }
        
        
    }
    
    func makeCall()
    {
        if let phoneNumber = contact?.socialPhone {
            let phone = "tel://\(phoneNumber)";
            let url = URL(string:phone)!;
            UIApplication.shared.openURL(url);
        }
        
    }
    
    func sphereDidSelected(_ index: Int) {
        
        switch index {
        case 0:
            //add contact to phone
            
            addContact()
        case 1:
            //save connection to app
             saveConnection()
        case 2:
            if phoneAvailable == 1 {
                makeCall()
            }else {
                //follow on twitter
                followContactOnTwitter()
            }
        case 3:
           //text message
          sendMessage()
        case 4:
            //follow on twitter
          followContactOnTwitter()
        default:
            break
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCaptureSession()
        containerView.isHidden = true
        scannedContact = 0
        menu?.removeFromSuperview()
    }
    
    //MARK: UI Methods
    
    
    //MARK: Capture Session Functions
    
    fileprivate func createCaptureSession()
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
    
    fileprivate func startCaptureSession()
    {
        captureSession?.startRunning()
    }
    
    fileprivate func stopCaptureSession()
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
    
            containerView.isHidden = true
            
            showingContact = 0
            lookingAtVideo = 0
            
          
            if pinVideo == 1 {
                self.videoView?.isHidden = false
                
            }else {
                self.videoView?.isHidden = true
                pauseVideo()
                self.videoView?.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
            
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
                        UIApplication.shared.openURL(URL(string: url)!)
                    }else {
                        
                        if showURLAlert == 0 {
                        let alert = SCLAlertView()
                        alert.addButton("Open webpage", action: { 
                            UIApplication.shared.openURL(URL(string: url)!)
                        })
                        
                            alert.showInfo(url, subTitle: "")
                            showURLAlert = 1
                        }
                    }
                
                    
    
                    
                }else if metadataObj.stringValue.range(of: "youtube:") != nil && metadataObj.stringValue.range(of: ".com") == nil {
                    
                    lookingAtVideo = 1
                    handleYoutubeVideo(metadataObj, barCodeObject: barCodeObject)
             
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
        
        showingContact = 1
        
         //Basically checking if its a different QNectcode or not, if it is we have to remove the sphere menu, because it will be different next time we scan it
        if oldContactString != metadataObj.stringValue {
            oldContactString = metadataObj.stringValue
            scannedContact = 0
            menu?.removeFromSuperview()
        }
        
        
    
        if Defaults["QuickScan"].bool == true {
            
            if scannedContact == 0 {
                let start = UIImage(named: "scanner_image")
                
                let callImage = UIImage(named: "call_button")
                let messageImage = UIImage(named: "message_button")
                let twitterImage = UIImage(named: "twitter_circle")
                let contactImage = UIImage(named: "contact_circle")
                let qnectImage = UIImage(named: "qnect_circle")
                
                var images = [contactImage!, qnectImage!]
                
                
                if contact!.socialPhone != "" {
                    images.append(callImage!)
                    images.append(messageImage!)
                    phoneAvailable = 1
                }
                
                if contact!.twitterScreenName != "" {
                    images.append(twitterImage!)
                }
                
                
                menu = SphereMenu(startPoint: CGPoint(x: 100, y: 100), startImage: start!, submenuImages:images, tapToDismiss:true)
                menu!.delegate = self
                
                self.containerView.addSubview(menu!)
                self.containerView.isHidden = false
                self.scannedContact = 1
                
                
                if Reachability.isConnectedToInternet() {
                    QnUtilitiy.retrieveContactProfileImageData(contact!, completion: { (data) in
                        
                        let image = UIImage(data: data)
                        self.contactImage = image
                        
                        self.menu?.start?.image = image
                        
                    })
                }else {
                    let image = ProfileImage.createProfileImage(contact!.firstName, last: contact!.lastName)
                    self.contactImage = image
                    self.menu?.start?.image = image
                }
              
            }
            
            let center = centerForBarcodeObject(barCodeObject)
            
            containerView.center = center
            containerView.isHidden = false
            containerView.isUserInteractionEnabled = true
        }else {
            self.stopCaptureSession()
            segueToContactViewController()
        }

        
    }
    
    
    //MARK : Youtube Handler Functions
    func playVideoWithId(_ videoId: String) {
        let html: String = String(format: youTubeVideoHTML, self.videoView!.frame.size.width, self.videoView!.frame.size.height, videoId)
        
        videoView!.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
        indicator?.startAnimating()
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicator?.stopAnimating()
    }
    
    func handleYoutubeVideo(_ metadataObj:AVMetadataMachineReadableCodeObject, barCodeObject:AVMetadataMachineReadableCodeObject)
    {
        if oldVideoString != metadataObj.stringValue{
            oldVideoString = metadataObj.stringValue
            gotVideo = 0
        }
        
        videoView?.isHidden = false
        
        
        if playerPaused == 1 {
            resumeVideo()
        }
        
        let center = centerForBarcodeObject(barCodeObject)
    
        if pinVideo == 0 {
            //Show youtube video on screen
            
            videoView?.center = center
            
        }else {
            videoView?.center = (videoView?.center)!
        }
        
        if gotVideo == 0 {
            
            UIView.animate(withDuration: 0.5
                , animations: {
                    self.videoView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            
            gotVideo = 1
            
            let message = metadataObj.stringValue
            let components = message?.components(separatedBy: ":")
            
            let videoID = components?[1]
            
            playVideoWithId(videoID!)
            
        }else {
            self.videoView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
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
    
    fileprivate func segueToContactViewController()
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
    
    
    
    //MARK: - Alerts
    
    func showCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
                                                    message: "You must give the app permission to add the contact first.",
                                                    preferredStyle: .alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .default,
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func showInternetError()
    {
        CRToastManager.showNotification(options: AlertOptions.statusBarOptionsWithMessage(AlertMessages.Internet, withColor: nil), completionBlock: { () -> Void in })
    }
    
    func showContactAddedToast()
    {
        CRToastManager.showNotification(options: AlertOptions.navBarOptionsWithMessage("Saved \(contact!.firstName) \(contact!.lastName) to contacts", withColor: UIColor.qnTealColor())){}
    }
    
    func showTwitterNotLinkedAlert()
    {
        
        let twitterAlert = SCLAlertView()
        twitterAlert.addButton("Link With Twitter") {
            QnUtilitiy.linkTwitterUserInBackground(User.current()!, completion: { (error) in
                if error != nil {
                    print("Error linking with Twitter")
                }else {
                    let twitterSuccess = SCLAlertView()
                    twitterSuccess.showCustom("Success!", subTitle: "Your are now linked with Twitter!", image: UIImage(named: "twitter_circle")!, style: .custom)
                }
            })
        }
        
        twitterAlert.showCustom("", subTitle: "You must be linked with Twitter to follow user", image: UIImage(named:"twitter_circle")! , style: .custom)
        
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    //MARK:Message Delegates
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
        
        scannedContact = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        if (showingContact == 0 && lookingAtVideo == 1) || pinVideo == 1{
            handlePinningOfVideo()
        }
    }
    
    func handlePinningOfVideo()
    {
        if pinVideo == 0{
            pinVideo = 1
            lookingAtVideo = 0
        }else {
            pinVideo = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.videoView?.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.pauseVideo()
                }, completion: { (bool) in
                    
            })
        }
    }
    
    
    func pauseVideo()
    {
        self.videoView?.stringByEvaluatingJavaScript(from: "player.pauseVideo()")
        playerPaused = 1
    }
    
    func resumeVideo()
    {
        self.videoView?.stringByEvaluatingJavaScript(from: "player.playVideo()")
        playerPaused = 0
    }
    
   
    
  
    
    
    
}



