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
import TransitionTreasury

class QnectCodeViewController: UIViewController {
    
    //MARK: Constants
    let kBorderRadius: CGFloat = 20.0

    //MARK: Properties
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    weak var modalDelegate: ModalViewControllerDelegate?
    lazy var dismissGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ModalViewController.panDismiss(_:)))
        self.view.addGestureRecognizer(pan)
        return pan
    }()
    
    
    //MARK: Outlets

    @IBOutlet weak var qnCodeImageView: UIImageView!
    @IBOutlet weak var borderView: UIView!
    
   
    
    
    //MARK: Actions
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.view.backgroundColor = UIColor.qnPurple
        
        borderView.layer.cornerRadius = kBorderRadius
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createQRCode()
    }
    
    
    //MARK: Functionality
    
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
    
    //MARK: Helpers
    
    func panDismiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began :
            guard sender.translation(in: view).y < 0 else {
                break
            }
            modalDelegate?.modalViewControllerDismiss(true, callbackData: nil)
        default : break
        }
    }
    
    

}

