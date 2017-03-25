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
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
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
        let currentUser = FIRAuth.auth()!.currentUser!
        
        databaseRef.child("users").child(currentUser.uid).observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            let encoder = QnEncoder(user: user)
            let qrCode = QNectCode(message: encoder.encodeSocialCode())
            
            qrCode.color = UIColor.qnPurple
            qrCode.backgroundColor = UIColor.white
            self.qnCodeImageView.image = qrCode.image
        })

       
    }
    
    

}
