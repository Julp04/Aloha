//
//  PlaceHolderViewController.swift
//  Aloha
//
//  Created by Panucci, Julian R on 6/4/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit

class PlaceHolderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        MainController.transitionManager.isEnabled = true
    }

}
