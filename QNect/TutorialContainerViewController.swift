//
//  TutorialContainerViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/30/2016
//  Copyright © 2016 QNect. All rights reserved.
//

import UIKit

class TutorialContainerViewController: UIViewController, UIPageViewControllerDelegate , UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    var pageViewController:UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        let infoTutVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoTutorialVC")
        let viewControllerArray = [infoTutVC!]

        self.pageViewController.setViewControllers(viewControllerArray, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        
    }

    //MARK: UIPageViewController Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: InfoTutorialVC.self) {
            return self.storyboard?.instantiateViewController(withIdentifier: "ScanTutorialVC")
        }else if viewController.isKind(of: ScanTutorialVC.self) {
            return self.storyboard?.instantiateViewController(withIdentifier: "ConnectTutorialVC")
        } else {
            return nil
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: ConnectTutorialVC.self) {
            return self.storyboard?.instantiateViewController(withIdentifier: "ScanTutorialVC")
        }else if viewController.isKind(of: ScanTutorialVC.self) {
            return self.storyboard?.instantiateViewController(withIdentifier: "InfoTutorialVC")
        }else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }

}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
