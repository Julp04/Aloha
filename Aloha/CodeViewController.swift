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

class CodeViewController: UIViewController {
    
    //MARK: Constants
    let kBorderRadius: CGFloat = 20.0

    //MARK: Properties
    
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

        self.view.backgroundColor = UIColor.qnGreenTeal
        
        let gradientView = GradientView(frame: view.bounds)
        gradientView.colors = [ UIColor.alohaYellow.cgColor, UIColor.alohaOrange.cgColor,]
        view.insertSubview(gradientView, at: 0)
        
        borderView.layer.cornerRadius = kBorderRadius
    }

    override func viewWillAppear(_ animated: Bool) {
        createQRCode()
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    
    //MARK: Functionality
    
    /**
     Uses QnEncoder to encode the string and generates a QRCode image out of that data. Sets the image view image to the QRcode image
     */
    fileprivate func createQRCode()
    {        
        QnClient.sharedInstance.currentUser { (user) in
            let encoder = QnEncoder(user: user)
            let qrCode = QNectCode(message: encoder.encodeUserInfo())
            qrCode.color = .black
            qrCode.backgroundColor = .white
            self.qnCodeImageView.image = qrCode.image
        }
    }

}

