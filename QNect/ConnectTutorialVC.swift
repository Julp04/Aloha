//
//  ConnectTutorialVC.swift
//  QNect
//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import UIKit

class ConnectTutorialVC: UIViewController {

    @IBOutlet weak var finishTutorialButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        finishTutorialButton.layer.cornerRadius = 2.0

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
