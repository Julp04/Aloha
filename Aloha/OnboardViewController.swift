//
//  OnboardViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/21/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import RevealingSplashView


class OnboardViewController: UIViewController {
    
    //MARK: Constants
    
    let kTitleFontSize:CGFloat = 23
    let kTitleYOffsetLength:CGFloat = 90
    let kTitleHeight:CGFloat = 30
    
    let kSubtitleFontSize:CGFloat = 17
    let kSubtitleHeight:CGFloat = 110
    let kSubtitleYOffsetLength:CGFloat = 30
    
    let kvideoURLString = "onboard.mp4"
    
    //MARK: Properties
    
    var backgroundPlayer : BackgroundVideo? // Declare an instance of BackgroundVideo called backgroundPlayer
    
    let titleArray = ["Welcome", "Create", "Scan", "Connect"]
    let subtitleArray = ["Connecting with friends has never been so easy. Use QNectcodes to quickly exchange info with friends", "Add contact info and other details to easily create your personal QNectcode", "Retreive users' info by quickly scanning their QNectcode. No internet connection required!", "Link different accounts like Twitter to easily follow other users without leaving the app"]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundPlayer = BackgroundVideo(on: self, withVideoURL: kvideoURLString)
        backgroundPlayer?.setUpBackground()
        
        configureScrollView()
        
        pageControl.numberOfPages = titleArray.count
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
         navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Setup
    
    func configureScrollView()
    {
        let size = view.bounds.size
        let contentSize = CGSize(width: size.width * CGFloat(titleArray.count), height: size.height)
        
        scrollView.contentSize = contentSize
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.delegate = self
        
        configureContentInScrollView()
    }
    
    func configureContentInScrollView()
    {
        
        for i in 0..<titleArray.count {
        
            let size = view.bounds.size
            
            let xOffset = (size.width * CGFloat(i))
            let yOffset = size.height / 2.0 + kTitleYOffsetLength
            
            
            let titleFrame = CGRect(x: xOffset, y: yOffset, width: size.width - 10, height: kTitleHeight)
            let titleLabel = UILabel(frame: titleFrame)
            titleLabel.text = titleArray[i]
            titleLabel.textColor = UIColor.white
            
            let normalFont = UIFont(name: "Gill Sans", size: kTitleFontSize)!
            let boldFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!, size: kTitleFontSize)
            
            titleLabel.font = boldFont
            titleLabel.textAlignment = .center
            
            let subtitleFrame = CGRect(x: xOffset + 10, y: yOffset + kSubtitleYOffsetLength, width: size.width - 20, height: kSubtitleHeight)
            let subtitleTextView = UITextView(frame: subtitleFrame)
            subtitleTextView.allowsEditingTextAttributes = false
            subtitleTextView.text = subtitleArray[i]
            subtitleTextView.textAlignment = .center
            
            let subtitleFont = UIFont(name: "Helvetica Neue", size: kSubtitleFontSize)
            subtitleTextView.font = subtitleFont
            subtitleTextView.backgroundColor = UIColor.clear
            subtitleTextView.textColor = UIColor.white
            subtitleTextView.isScrollEnabled = false
            subtitleTextView.isEditable = false
            subtitleTextView.isUserInteractionEnabled = false
            
            scrollView.addSubview(titleLabel)
            scrollView.addSubview(subtitleTextView)
        }
    }
}

extension OnboardViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width;
        let fractionalPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage));
        self.pageControl.currentPage = page;
        
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
