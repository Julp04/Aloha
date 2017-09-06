//
//  TodayViewController.swift
//  Aloha Widget
//
//  Created by Panucci, Julian R on 9/4/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var profileImageView0: ProfileImageView!
    @IBOutlet weak var profileImageView1: ProfileImageView!
    @IBOutlet weak var profileImageView2: ProfileImageView!

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label2: UILabel!
    var userNames = [String?]()
    var uids = [String?]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let profileImageViews = [profileImageView0, profileImageView1, profileImageView2]
       let  labels = [label0, label1, label2]
        
        let userDefaults = UserDefaults(suiteName: "group.io.sayaloha.aloha")
        if let users = userDefaults?.object(forKey: "recentlyAdded") as? [String: [Any]] {
            
            let count = users["uid"]!.count
            
            for i in 0 ..< count {
                uids.append(users["uid"]?[i] as? String)
                userNames.append(users["username"]?[i] as? String)
                
                labels[i]?.text = userNames[i]

                if let imageData = users["imageData"]?[i] as? Data {
                    let image = UIImage(data: imageData)
                    profileImageViews[i]?.image = image
                }else {
                    profileImageViews[i]?.isHidden = true
                    labels[i]?.isHidden = true
                }
                
                profileImageViews[i]?.onClick =  {
                    if self.userNames[i] != nil {
                        self.extensionContext?.open(URL(string:"alohaExtension://\(self.uids[i]!)")!, completionHandler: nil)
                    }
                }
            }
            
            for i  in 0 ..< profileImageViews.count {
                if profileImageViews[i]?.image == nil {
                    profileImageViews[i]?.isHidden = true
                    labels[i]?.isHidden = true
                }
            }
        }

    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
