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
import ReachabilitySwift
import RSKImageCropper
import MessageUI



class ProfileViewControllerOtherUser: UITableViewController {
    
    //MARK: Constants
    let kAccountsHeaderTitle = "Accounts"
    let kHeaderHeight: CGFloat = 30.0
    let kHeaderFontSize: CGFloat = 13.0
    let kHeaderFontName = "Futura"
    
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 10
    let collectionRightInset: CGFloat = 10
    
    
    //MARK: Properties
    var user: User!
    let connectionsHeaderTitle = "Common Connections"
    var colorView: GradientView!
    var profileManager: ProfileManager!
    
    var profileHeight: CGFloat = 0.0
    var twitterButton: SwitchButton?
    var followingStatus: FollowingStatus = .notFollowing
    var settingsAlert: UIAlertController!
    
   
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
    @IBOutlet weak var accountsCollectionView: UICollectionView!
    //MARK: Actions
    
    @IBAction func settingsAction(_ sender: Any) {
        present(settingsAlert, animated: true, completion: nil)
    }
    
    @IBAction func dimissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: Configure Before Load
    
    
    func configureViewController(user: User)
    {
        self.user = user
    }
    
    
    fileprivate func setUpViewController() {
        //Setup view controller as if we were viewing someone else's profile
        //Ex: Follow button would be displayed, we could see call, message, email buttons (only if user had those), Show common connections with current user, Accounts button would change so you could follow or add the contact
        
        navigationController?.navigationBar.topItem?.title = user.username
        
        
        
        callButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.callUser), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.messageUser), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.emailUser), for: .touchUpInside)
        
      
        updateContactButtons()
        
        //Get profile image
        getProfileImage()
        
        profileManager = ProfileManager(user: user, viewController: self)
    
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
    
        colorView = GradientView(frame: tableView.bounds)
        colorView.colors = [#colorLiteral(red: 0.05098039216, green: 0.9607843137, blue: 0.8, alpha: 1).cgColor, #colorLiteral(red: 0.0431372549, green: 0.5764705882, blue: 0.1882352941, alpha: 1).cgColor]
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.addSubview(colorView)
        tableView.backgroundView = backgroundView
        
        
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
        
        
        updateUI()
        
        listenForUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            return profileHeight
        }
        
        return 125
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
    
    func listenForUpdates() {
        
        //This will get called if the user you are viewing makes a change to his profile as you are viewing it.
        QnClient.sharedInstance.getUpdatedInfoForUser(user: user) { (updatedUser) in
            self.user = updatedUser
            self.updateUI()
        }
        
        QnClient.sharedInstance.getFollowStatus(user: user) { (status) in
            self.followingStatus = status
            self.updateUI()
        }
    }
    
    func updateUI() {
        updateFollowButton()
        updateSettingsAlert()
        updateUserInfoLabels()
        updateContactButtons()
    }
    
    func updateFollowButton() {
        self.followOrEditProfileButton.removeTarget(nil, action: nil, for: .allEvents)
        
        var buttonText = ""
        var action: Selector
        switch followingStatus {
        case .accepted:
            buttonText = "Following"
            action = #selector(ProfileViewControllerOtherUser.showUnfollowAction)
        case .pending:
            buttonText = "Pending"
            action = #selector(ProfileViewControllerOtherUser.showCancelRequestAlert)
        case .blocking:
            buttonText = "Blocked"
            action = #selector(ProfileViewControllerOtherUser.showUnblockAction)
        case .notFollowing:
            buttonText = "Follow"
            action = #selector(ProfileViewControllerOtherUser.follow)
        }
        
        self.followOrEditProfileButton.setTitle(buttonText, for: .normal)
        self.followOrEditProfileButton.addTarget(self, action: action, for: .touchUpInside)
    }
    
    func updateSettingsAlert() {
        let name = "\(user.firstName!) \(user.lastName!)"
        
        settingsAlert = UIAlertController(title: name , message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        settingsAlert.addAction(cancelAction)
        
        if followingStatus != .blocking {
            let blockAction = UIAlertAction(title: "Block", style: .destructive) { (action) in
                QnClient.sharedInstance.block(user: self.user)
            }
            settingsAlert.addAction(blockAction)
        }else {
            let unblockAction = UIAlertAction(title: "Unblock", style: .destructive, handler: { (action) in
                QnClient.sharedInstance.unblock(user: self.user)
            })
            settingsAlert.addAction(unblockAction)
        }
        
    }
    
    func updateUserInfoLabels() {
        let birthdate = user.birthdate?.asDate()
        let age = birthdate?.age
        
        if user.location != nil && age != nil {
            locationLabel.text = "\(user.location!) | \(age!)"
        }else {
            locationLabel.text = user.location ?? age
        }
        aboutLabel.text = user.about
        nameLabel.text = "\(user.firstName!) \(user.lastName!)"
        
        
        //Check whether other info is available
        aboutLabel.isHidden = user.about == nil
        locationLabel.isHidden = (user.location == nil && age == nil)
        
        profileHeight = calculateProfileViewHeight()
    }
    
    func updateContactButtons() {
        callButton.isHidden = user.phone == nil
        messageButton.isHidden = user.phone == nil
        emailButton.isHidden = user.personalEmail == nil
    }
    
    
    func calculateProfileViewHeight() -> CGFloat
    {
        let y = statsStackView.frame.origin.y
        let finalPosition = y
        
        return finalPosition
    }
    
    func getProfileImage() {
        
        self.profileImageView.image = ProfileImageCreator.create(user.firstName, last: user.lastName)
        
        
        if user.profileImage == nil {
            if Reachability.isConnectedToInternet() {
                QnClient.sharedInstance.getProfileImageForUser(user: user, completion: { (profileImage, error) in
                    if error != nil {
                        print(error!)
                    }else {
                        self.user.profileImage = profileImage
                        self.profileImageView.image = profileImage
                    }
                })
            }
        }else {
            self.profileImageView.image = user.profileImage
        }
    }
    
    //MARK: Functionality
    
    func follow() {
    
        QnClient.sharedInstance.follow(user: user)
    }
    
    func showCancelRequestAlert() {
        
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        let cancelRequestAction = UIAlertAction(title: "Cancel follow request", style: .destructive) { (action) in
            QnClient.sharedInstance.cancelFollow(user: self.user)
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(cancelRequestAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func messageUser() {
        if let phoneNumber = user.phone {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: false, completion: nil)
        }
    }
    
    func callUser() {
        let callAlert = UIAlertController(title: "Call \(user.firstName!) \(user.lastName!)", message: nil, preferredStyle: .alert)
        let callAction = UIAlertAction(title: "Call", style: .default) { (action) in
            if let phoneNumber = self.user.phone {
                let phone = "tel://\(phoneNumber)";
                let url = URL(string:phone)!;
                UIApplication.shared.openURL(url);
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        callAlert.addAction(cancelAction)
        callAlert.addAction(callAction)
        
        present(callAlert, animated: true, completion: nil)
    }
    
    func emailUser() {
        if let email = user.personalEmail {
            let emailVC = MFMailComposeViewController()
            emailVC.setToRecipients([email])
            emailVC.mailComposeDelegate = self
            
            present(emailVC, animated: true, completion: nil)
        }
        
    }
    
    func showUnblockAction() {
        let alert = UIAlertController(title: self.user.username, message: nil, preferredStyle: .actionSheet)
        
        let unblockAction = UIAlertAction(title: "Unblock", style: .destructive) { (action) in
            QnClient.sharedInstance.unblock(user: self.user)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(unblockAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func showUnfollowAction() {
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { (action) in
            QnClient.sharedInstance.unfollow(user: self.user)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(unfollowAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
   
}

extension ProfileViewControllerOtherUser: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileManager.numberOfLinkedAccounts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let button = profileManager.buttonAtIndexPath(indexPath: indexPath)
        button.tag = 111
        
        if (cell.contentView.viewWithTag(111)) != nil {
        }else {
            cell.contentView.addSubview(button)
        }
        
        return cell
    }

    
}

extension ProfileViewControllerOtherUser: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionTopInset, collectionLeftInset, collectionBottomInset, collectionRightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tableViewCellHeight: CGFloat = tableView.rowHeight
        let collectionItemWidth: CGFloat = tableViewCellHeight - (collectionLeftInset + collectionRightInset)
        let collectionViewHeight: CGFloat = collectionItemWidth
        
        return CGSize(width: 125.0, height: 75.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

extension ProfileViewControllerOtherUser: UICollectionViewDelegate {
    
}

extension ProfileViewControllerOtherUser: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ProfileViewControllerOtherUser: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}

