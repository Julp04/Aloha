//
//  ContainerViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    //MARK: Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    var pageViewController:UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
     
        
       
        
        let scannerNavController = self.storyboard?.instantiateViewController(withIdentifier: ViewControllerIdentifier.Scanner) as! UINavigationController
        let viewControllerArray = [scannerNavController]
        
        self.pageViewController.setViewControllers(viewControllerArray, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    //MARK: UIPageViewController Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let navVC = viewController as? UINavigationController {
            let vc = navVC.topViewController
            if vc is ScannerViewController
            {
                return self.storyboard?.instantiateViewController(withIdentifier: ViewControllerIdentifier.Connections) as! UINavigationController
            }else if vc is QnectCodeViewController {
                return self.storyboard?.instantiateViewController(withIdentifier: ViewControllerIdentifier.Scanner) as! UINavigationController
            }
            
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let navVC = viewController as? UINavigationController {
            let vc = navVC.topViewController
            
            if vc is ScannerViewController {
                return self.storyboard?.instantiateViewController(withIdentifier: ViewControllerIdentifier.QNectCode) as! UINavigationController
            }else if vc is ConnectionsViewController {
                return self.storyboard?.instantiateViewController(withIdentifier: ViewControllerIdentifier.Scanner) as! UINavigationController
            }
        }
        
        return nil
    }
    
    

    
}

