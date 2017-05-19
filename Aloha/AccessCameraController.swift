//
//  AccessCameraController.swift
//  Aloha
//
//  Created by Panucci, Julian R on 5/19/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class AccessCameraController: UIViewController {
    
    //MARK: Constants
    
    //MARK: Properties
    
    //MARK: Outlets
    
    //MARK: Actions
    
    @IBAction func cameraSettingsAction(_ sender: Any) {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   

}
