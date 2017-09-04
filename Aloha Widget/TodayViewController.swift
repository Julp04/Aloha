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
    @IBOutlet weak var profileImageView: ProfileImageView!
    var userName:String?
    var uid: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults(suiteName: "group.io.sayaloha.aloha")
        if let users = userDefaults?.object(forKey: "recentlyAdded") as? [String: [String]] {
            
            uid = users["uid"]?[0]
            userName = users["username"]?[0]
            let url = users["photoURL"]?[0]
            ImageDownloader.downloadImage(url: url, completion: { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.profileImageView.image = image
                    case .failure(let error):
                        print(error)
                    }
                }
            })
        }
        
        profileImageView.onClick =  {
            if self.userName != nil {
                self.extensionContext?.open(URL(string:"alohaExtension://\(self.uid!)")!, completionHandler: nil)
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
