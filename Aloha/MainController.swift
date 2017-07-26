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
import PTPopupWebView
import Crashlytics
import FirebaseAuth
import EasyTipView

class MainController: PageboyViewController {
    
    //MARK: Constants
    let kDismissString = "Dismiss"
    let kPinchVelocity = 8.0
    var showQRCodeTip: EasyTipView!
    

    //MARK: Properties
    var client = QnClient()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    var placeHolderViewController: UIViewController!
    var profileNavController: UINavigationController!
    var connectionsNavController: UINavigationController!
    
    var profileViewController: ProfileViewControllerCurrentUser!
    var connectionsViewController: ConnectionsViewController!
    
    var colorView: GradientView!
    var contactImage:UIImage?
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var contact: User!
    var qrCodeFrameView = UIImageView()
    static var transitionManager = TransitionManager(segueIdentifier: "CodeSegue")
    
    var codeButton: UIButton!
    var scanner: Scanner!
    
    var scannedContact = 0
    var toFromIndex: (Int, Int) = (0, 0)

    var scannerCanScan = true
    var message: String?
    
    
    //MARK: Lifecycle
    
     override func viewDidLoad() {
        super.viewDidLoad()
       
        
        showQRCodeTip = EasyTipView(text: "Tap here to share your QR code!")
        
        
        colorView = GradientView(frame: view.frame)
        view.insertSubview(colorView, at: 0)
        colorView.colors = [ #colorLiteral(red: 0.123675175, green: 0.9002516866, blue: 0.7746840715, alpha: 1).cgColor, #colorLiteral(red: 0.02568417229, green: 0.4915728569, blue: 0.614921093, alpha: 1).cgColor,]
        colorView.alpha = 0.0
        
        scanner = Scanner(view: view, scanTypes: [.qr])
        scanner.delegate = self
        scanner.pinchToZoom = true
        
        
        PermissonUtility.isCameraAuthorized { (success) in
            if !success {
                DispatchQueue.main.async {
                    let accessCameraController = self.storyboard?.instantiateViewController(withIdentifier: "AccessCameraController") as! AccessCameraController
                    self.present(accessCameraController, animated: true, completion: nil)
                    return
                }
            }
        }
        

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavController = storyboard.instantiateViewController(withIdentifier: "ProfileViewControllerCurrentUserNav") as! UINavigationController
        connectionsNavController = storyboard.instantiateViewController(withIdentifier: "ConnectionsViewControllerNav") as! UINavigationController
        
        placeHolderViewController = PlaceHolderViewController()
        placeHolderViewController.view.backgroundColor = .clear
        codeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        codeButton.setImage(#imageLiteral(resourceName: "code_button"), for: .normal)
        codeButton.addTarget(self, action: #selector(MainController.presentCodeController), for: .touchUpInside)
        codeButton.center = CGPoint(x: view.center.x, y: view.bounds.height - 40)
        placeHolderViewController.view.addSubview(codeButton)
        
        profileViewController = profileNavController.viewControllers.first as! ProfileViewControllerCurrentUser
        connectionsViewController = connectionsNavController.viewControllers.first as! ConnectionsViewController
        
        client.currentUser { (currentUser) in
            
            guard let currentUser = currentUser else {
                self.client.signOut()
                let onboardNav = self.storyboard?.instantiateViewController(withIdentifier: "OnboardNavController") as! UINavigationController
                self.present(onboardNav, animated: false, completion: nil)
                return
            }
            
            
            self.profileViewController.configureViewController(currentUser: currentUser)
        }
        
        MainController.transitionManager.sourceViewController = self
        
        self.dataSource = self
        self.delegate = self
        self.bounces = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Defaults[Tutorial.revealQRCode].bool == false || Defaults[Tutorial.revealQRCode].bool == nil {
            showQRCodeTip.showTip(animated: true, for: codeButton, within: nil)
            Defaults[Tutorial.revealQRCode] = true
            Defaults.synchronize()
        }
    }
    
    
    func presentCodeController() {
        self.performSegue(withIdentifier: "CodeSegue", sender: self)
        showQRCodeTip.dismiss()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        scanner?.startCaptureSession()
        MainController.transitionManager.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "CodeSegue" {
            let codeViewController = segue.destination
            codeViewController.transitioningDelegate = MainController.transitionManager
            MainController.transitionManager.presentedViewController = codeViewController
        }else if segue.identifier == "ProfileSegue" {
                let user = sender as! User
                let profileNavController = segue.destination as! UINavigationController
                let profileViewController = profileNavController.viewControllers.first as! ProfileViewControllerCurrentUser
                profileViewController.configureViewController(currentUser: user)
        }
    }
}

//MARK: Scanner Delegate

extension MainController: ScannerDelegate {
    
    func scannerDidScan(qrCode: AVMetadataMachineReadableCodeObject) {
        guard scannerCanScan else {
            return
        }
        
        let scan = Scan(data: qrCode.stringValue)
        client.add(scan: scan)
        
        if let contact = QnDecoder.decodeQRCode(qrCode.stringValue) {
            //todo:check if user still exists
            //somepoint later down the road there could be codes out there that are not tied to any accounts, we either do not want to show this account or we do not want to be able to follow it
            
            self.contact = contact
            
            scanner.stopCaptureSession()
          
            let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewControllerOtherUser") as! ProfileViewControllerOtherUser
            profileViewController.configureViewController(user: self.contact)
    
            let navController = UINavigationController(rootViewController: profileViewController)
            self.present(navController, animated: true, completion: nil)
            
            
        }else if let url = qrCode.stringValue.checkForURL() {
            
            let popupvc = PTPopupWebViewController()
            popupvc.popupView.URL(string: url)
            let closeButton = PTPopupWebViewButton(type: .custom).title("Close").foregroundColor(UIColor.qnBlue)
            closeButton.handler({
                self.scanner.startCaptureSession()
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
            scanner.stopCaptureSession()
        }else {
            let message = qrCode.stringValue
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: kDismissString, style: UIAlertActionStyle.default) {_ in
                self.scanner.startCaptureSession()
            })
            self.present(alert, animated: true)
            scanner.stopCaptureSession()
        }
    }
    
}

//MARK: Pageboy Delegate

extension MainController: PageboyViewControllerDelegate {
    
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
        MainController.transitionManager.isEnabled = index != 1 ? false: true
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
            colorView.colors = [ #colorLiteral(red: 0.123675175, green: 0.9002516866, blue: 0.7746840715, alpha: 1).cgColor, #colorLiteral(red: 0.02568417229, green: 0.4915728569, blue: 0.614921093, alpha: 1).cgColor,]
            colorView.alpha = 1 - position.x
//            rightBarButton.alpha = position.x
        case (2, 1), (1, 2):
            colorView.colors = [#colorLiteral(red: 0.05098039216, green: 0.9607843137, blue: 0.8, alpha: 1).cgColor, #colorLiteral(red: 0.0431372549, green: 0.5764705882, blue: 0.1882352941, alpha: 1).cgColor]
            colorView.alpha = position.x - 1
        default:
            break
        }
    }

}

//MARK: Pageboy Datasource

extension MainController: PageboyViewControllerDataSource {
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // return array of view controllers
        return [profileNavController, placeHolderViewController, connectionsNavController]
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // set ScannerViewController as first controller you see at index 1. Which is in the middle
        return PageIndex.at(index: 1)
    }
    
}


