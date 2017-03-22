//
//  AccountsViewController.swift
//  
//
//  Created by Panucci, Julian R on 3/17/17.
//
//

import UIKit
import RAMPaperSwitch

class AccountsViewController: UIViewController {

    //MARK: Properties
    
    
    
    //MARK: Outlets
    
    
    
    
    
    //MARK: Actions
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TwitterClient.client.follow(screenName: "qnect_app") { (error) in
            print(error ?? "No error")
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.qnPurple

//        let snowflake = Snowflake(view: view, particleImages: [#imageLiteral(resourceName: "twitter_on")])
        let snowflake = Snowflake(view: view, particles: [#imageLiteral(resourceName: "twitter_on")], color: UIColor.black)
        
        
        
        

        
        
   

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Functionality


}
