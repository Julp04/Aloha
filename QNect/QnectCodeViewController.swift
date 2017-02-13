//
//  QnectCodeViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import RKDropdownAlert

class QnectCodeViewController: UIViewController {
    

    @IBOutlet weak var qnCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.view.backgroundColor = UIColor.white
    
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        createQRCode()
    }
    
    
    /**
     Uses QnEncoder to encode the string and generates a QRCode image out of that data. Sets the image view image to the QRcode image
     */
    fileprivate func createQRCode()
    {
        
        User.currentUser(userData: (FIRAuth.auth()?.currentUser)!) { (user) in
            let encoder = QnEncoder(user: user)
            let qrCode = QNectCode(message: encoder.encodeSocialCode())
            
            qrCode.color = UIColor.qnPurple
            qrCode.backgroundColor = UIColor.white
            self.qnCodeImageView.image = qrCode.image
        }

       
    }
    
    

}
