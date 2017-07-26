//
//  CodeViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import RKDropdownAlert
import EasyTipView

class CodeViewController: UIViewController {
    
    //MARK: Constants
    let kBorderRadius: CGFloat = 20.0

    //MARK: Properties
    var qrCodeTip: EasyTipView!
    var client = QnClient()
    
    //MARK: Outlets

    @IBOutlet weak var qnCodeImageView: UIImageView!
    @IBOutlet weak var borderView: UIView!
    
   
    
    
    //MARK: Actions
    
    @IBAction func dimissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrCodeTip = EasyTipView(text: "Present your QR code for others to scan, to quickly swap info!")

        self.view.backgroundColor = UIColor.clear
        
        borderView.layer.cornerRadius = kBorderRadius
    }

    override func viewWillAppear(_ animated: Bool) {
        createQRCode()
        MainController.transitionManager.isEnabled = true
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Defaults[Tutorial.qrCodeShown].bool == false || Defaults[Tutorial.qrCodeShown].bool == nil {
            qrCodeTip.showTip(animated: true, for: qnCodeImageView, within: nil)
            Defaults[Tutorial.qrCodeShown] = true
            Defaults.synchronize()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        qrCodeTip.dismiss()
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    //MARK: Functionality
    
    /**
     Uses QnEncoder to encode the string and generates a QRCode image out of that data. Sets the image view image to the QRcode image
     */
    fileprivate func createQRCode()
    {        
        client.currentUser { (user) in
            let encoder = QnEncoder(user: user!)
            let qrCode = QNectCode(message: encoder.encodeUserInfo())
            qrCode.color = .black
            qrCode.backgroundColor = .white
            self.qnCodeImageView.image = qrCode.image
        }
    }

}

