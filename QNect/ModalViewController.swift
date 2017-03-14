//
//  ModalViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/12/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

import TransitionTreasury

class ModalViewController: UIViewController {

    weak var modalDelegate: ModalViewControllerDelegate?
    
    lazy var dismissGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ModalViewController.panDismiss(_:)))
        self.view.addGestureRecognizer(pan)
        return pan
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load")
    }
    
    
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
    
    deinit {
        print("Modal deinit.")
    }


}
