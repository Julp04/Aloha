//
//  ProfileViewContoller.swift
//  QNect
//
//  Created by Panucci, Julian R on 3/29/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import JPLoadingButton
import FirebaseAuth
import Firebase

class ProfileViewContoller: UITableViewController {
    
    //MARK: Constants
    let kAccountsHeaderTitle = "Accounts"
    let kHeaderHeight: CGFloat = 30.0
    let kHeaderFontSize: CGFloat = 13.0
    let kHeaderFontName = "Futura"
    
    
    //MARK: Properties
    var displayCurrentUserProfile = true
    var user: User!
    var connectionsHeaderTitle: String!
    
    var profileHeight: CGFloat = 0.0
    
   
    //MARK: Outlets
  
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followOrEditProfileButton: JPLoadingButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var statsStackView: UIStackView!
    //MARK: Actions
    
    
    //MARK: Configure Before Load
    
    
    func configureViewController(displayCurrentUserProfile: Bool, user: User)
    {
        self.displayCurrentUserProfile = displayCurrentUserProfile
        self.user = user
//        user.about = "I am cool"
        user.location = "Pittsburgh, PA"
        user.age = "23"
    }
    
    fileprivate func configureViewControllerForCurrentUser() {
        //Setup view controller only if we were to view as ourself
        //Ex: Follow button would be EditProfileButton, Common Connections would be Recent Added Connections, Won't show call, message, email buttons, Accounts buttons would link your accounts to your profile
       
        
        
        //Cannot email, message, or call self...
        callButton.isHidden = true
        messageButton.isHidden = true
        emailButton.isHidden = true
        
        //Edit profile button instead of follow button
        followOrEditProfileButton.setTitle("Edit Profile", for: .normal)
        followOrEditProfileButton.addTarget(self, action: #selector(ProfileViewContoller.editProfile), for: .touchUpInside)
        
        connectionsHeaderTitle = "Recently Added"
        
        //ProfileImageView
        profileImageView.onClick = {
            //todo:Change profilePicture
        }

    }
    
    fileprivate func configureViewControllerForOtherUser() {
        //Setup view controller as if we were viewing someone else's profile
        //Ex: Follow button would be displayed, we could see call, message, email buttons (only if user had those), Show common connections with current user, Accounts button would change so you could follow or add the contact
        
        callButton.addTarget(self, action: #selector(ProfileViewContoller.callUser), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(ProfileViewContoller.messageUser), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(ProfileViewContoller.emailUser), for: .touchUpInside)
        
        callButton.isHidden = user.socialPhone == nil
        messageButton.isHidden = user.socialPhone == nil
        emailButton.isHidden = user.socialEmail == nil
        
        //Follow button instead of editProfile button
        configureFollowButton()
        
        connectionsHeaderTitle = "Common Connections"
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
         displayCurrentUserProfile ? configureViewControllerForCurrentUser() : configureViewControllerForOtherUser()
        
        if user.location != nil && user.age != nil {
            locationLabel.text = "\(user.location!) | \(user.age!)"
        }else {
            locationLabel.text = user.location ?? user.age
        }
        
        aboutLabel.text = user.about
        
       
        
        //Check whether other info is available
        aboutLabel.isHidden = user.about == nil
        locationLabel.isHidden = (user.location == nil && user.age == nil)

        profileHeight = calculateProfileViewHeight()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            return profileHeight
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = CGRect(x: 5.0, y: 0, width: tableView.frame.width, height: kHeaderHeight)
        let headerView = UIView(frame: headerFrame)
        headerView.backgroundColor = .clear
        
        let headerLabel = UILabel(frame: headerFrame)
        headerLabel.font = UIFont(name: kHeaderFontName, size: kHeaderFontSize)
        let fadedWhite = UIColor(white: 1.0, alpha: 0.5)
        headerLabel.textColor = fadedWhite

        switch section {
        case 1:
            headerLabel.text = kAccountsHeaderTitle
        case 2:
            headerLabel.text = connectionsHeaderTitle
        default:
            break
        }
    
        headerView.addSubview(headerLabel)
        
       return headerView
    }
    
    //MARK: UI Helper
    
    func calculateProfileViewHeight() -> CGFloat
    {
        let y = statsStackView.frame.origin.y
        let finalPosition = y + statsStackView.frame.size.height
        
        return finalPosition
    }
    
    func configureFollowButton() {
        //todo: Check whether current user is following displayed user
        let isFollowing = false
        let buttonText = isFollowing ? "Following" : "Follow"
        
        followOrEditProfileButton.setTitle(buttonText, for: .normal)
        followOrEditProfileButton.addTarget(self, action: #selector(ProfileViewContoller.follow), for: .touchUpInside)
    }
    
    //MARK: Functionality
    
    func editProfile() {
        //todo:Segue to editProfileViewController
        
        
    }
    
    func follow() {
    
    }
    
    func messageUser() {
        
    }
    
    func callUser() {
        
    }
    
    func emailUser() {
        
    }


}

