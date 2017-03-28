//
//  MainController.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/28/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import Pageboy

class MainController: PageboyViewController, PageboyViewControllerDelegate, PageboyViewControllerDataSource {

    var scannerViewController: ScannerViewController!
    var profileViewController: QnTableViewController!
    var connectionsViewController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        scannerViewController = storyboard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! QnTableViewController
        connectionsViewController = storyboard.instantiateViewController(withIdentifier: "ConnectionsViewControllerNav") as! UINavigationController

        self.dataSource = self
    }
    
    //MARK: Pageboy Datasource

    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // return array of view controllers
        return [profileViewController, scannerViewController, connectionsViewController]
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // use default index
        return nil
    }

    
    // MARK: PageboyViewControllerDelegate
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAtIndex index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        
        
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPosition position: CGPoint,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
     
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAtIndex index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
    }

}
