//
//  InterfaceController.swift
//  QNectWatch Extension
//
//  Created by Panucci, Julian R on 3/5/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var qnectCodeImageView: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
       
    }
    @IBAction func button() {
       
        WCSession.default().sendMessage(["hello":"hi"], replyHandler: { (dict) in
            print(dict)
        }) { (error) in
            print(error)
        }
        
    }
    
    var session : WCSession!
    
    var imageData:Data!
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self;
            session.activate()
        }
    
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    
        
        
        super.willActivate()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
  
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        imageData = message["data"] as! Data
        
        let image = UIImage(data: imageData)
        
        qnectCodeImageView.setImage(image)
        
    }
    
   
   
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        
    }
    
   
    


}
