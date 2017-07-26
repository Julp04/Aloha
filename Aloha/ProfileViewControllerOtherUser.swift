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
import FontAwesome_swift
import RKDropdownAlert



class ProfileViewControllerOtherUser: UITableViewController {
    
    //MARK: Constants
    let kAccountsHeaderTitle = "Accounts"
    let kConnectionsHeaderTitle = "Common Connections"
    let kHeaderHeight: CGFloat = 30.0
    let kHeaderFontSize: CGFloat = 13.0
    let kHeaderFontName = "Futura"
    let kNavigationBarHeight: CGFloat = 64
    
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 10
    let collectionRightInset: CGFloat = 10
    
    
    //MARK: Properties
    var client: QnClient = QnClient()
    var user: User!
    
    var colorView: GradientView!
    var accountManager: OtherUserAccountManager!
    var isBlocked: Bool = false
    
    var profileHeight: CGFloat = 0.0
    var twitterButton: SwitchButton?
    var followingStatus: FollowingStatus = .notFollowing
    var settingsAlert: UIAlertController!
    
    var backgroundView: UIView!
    var settingsButton: UIBarButtonItem!
    
    var contactButtons = [UIButton]()
    
   
    //MARK: Outlets
    
    @IBOutlet weak var followRequestImageView: ProfileImageView!
  
    @IBOutlet weak var imageViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followOrEditProfileButton: JPLoadingButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var faceTimeButton: UIButton!
    
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var followStackView: UIStackView!
    @IBOutlet weak var contactButtonsStackView: UIStackView!
    @IBOutlet weak var profileImageStackView: UIStackView!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var aboutStackView: UIStackView!
    
    @IBOutlet weak var scansLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var accountsCollectionView: UICollectionView!
    
    
    
    //MARK: Actions
  
    
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
        
        
        
        callButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.callUser), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.messageUser), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.emailUser), for: .touchUpInside)
        faceTimeButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.faceTimeUser), for: .touchUpInside)
        
        contactButtons = [callButton, messageButton, emailButton, faceTimeButton]
        
        updateContactButtons()
        
        //Get profile image
        getProfileImage()
    }
    
    //MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        listenForUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_icon"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(ProfileViewControllerOtherUser.settingsAction(_:)))
        navigationItem.setRightBarButton(settingsButton, animated: false)
        navigationItem.title = user.username
        navigationItem.titleView?.tintColor = .white
        
        navigationController?.delegate = self
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        imageViewSpinner.isHidden = true
        
        setUpViewController()
    
        colorView = GradientView(frame: tableView.bounds)
        colorView.colors = [#colorLiteral(red: 0.05098039216, green: 0.9607843137, blue: 0.8, alpha: 1).cgColor, #colorLiteral(red: 0.0431372549, green: 0.5764705882, blue: 0.1882352941, alpha: 1).cgColor]
        
        backgroundView = UIView(frame: tableView.bounds)
        backgroundView.addSubview(colorView)
        
        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
        
        self.accountManager = OtherUserAccountManager(user: self.user, viewController: self)
        accountManager.delegate = self
        
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let height = calculateProfileViewHeight() + kNavigationBarHeight + 5
            
            for button in contactButtons {
                if !button.isHidden {
                    return height + 30.0
                }
            }
            return height
        }
        
        return 115
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
            //todo: Common connections feature
            headerLabel.text = ""
        default:
            break
        }
    
        headerView.addSubview(headerLabel)
        
       return headerView
    }
    
    //MARK: UI Helper
    
    func listenForUpdates() {
        
//        This will get called if the user you are viewing makes a change to his profile as you are viewing it.
        client.getUpdatedInfoForUser(user: user) { (updatedUser) in
            self.user = updatedUser
            if let profileImage = self.user.profileImage {
                DispatchQueue.main.async {
                    self.profileImageView.image = profileImage
                }
            }else {
                //The profile image has not been loaded
                //Download user profile image
                ImageDownloader.downloadImage(url: updatedUser.profileImageURL) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.user.profileImage = image
                            self.profileImageView.image = image
                        case .failure:
                            break
                        }
                    }
                }
            }
            //Set accountManager again with updated user,to see account buttons
            DispatchQueue.main.async {
                self.accountManager.update(user: self.user)
                self.accountsCollectionView.reloadData()
                self.updateUI()
                self.tableView.reloadData()
            }
        }
        
        client.getFollowStatus(user: user) { (status) in
            self.followingStatus = status
            self.updateUI()
            self.tableView.reloadData()
        }
        
        client.isBlockedBy(user: user) { (isBlocked) in
            self.isBlocked = isBlocked
            self.tableView.reloadData()
        }
        
        client.getFollowing(forUser: self.user) { (following) in
            DispatchQueue.main.async {
                self.followingLabel.text = "\(following.count)"
            }
        }
        
        client.getFollowers(forUser: self.user) { (followers) in
            DispatchQueue.main.async {
                self.followersLabel.text = "\(followers.count)"
            }
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
        var buttonColor = UIColor(white: 1.0, alpha: 0.5)
        var buttonTextColor = UIColor.qnBlue
        
        switch followingStatus {
        case .accepted:
            buttonColor = .qnBlue
            buttonTextColor = .white
            buttonText = "Following"
            action = #selector(ProfileViewControllerOtherUser.showUnfollowAction)
        case .pending:
            buttonText = "Pending"
            action = #selector(ProfileViewControllerOtherUser.showCancelRequestAlert)
        case .blocking:
            buttonColor = .qnRed
            buttonTextColor = .white
            buttonText = "Blocked"
            action = #selector(ProfileViewControllerOtherUser.showUnblockAction)
        case .notFollowing:
            buttonText = "Follow"
            action = #selector(ProfileViewControllerOtherUser.follow)
        }
        
        self.followOrEditProfileButton.setTitleColor(buttonTextColor, for: .normal)
        self.followOrEditProfileButton.backgroundColor = buttonColor
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
        
        let reportingAction = UIAlertAction(title: "Report", style: .destructive) { (action) in
            self.showReportingAction()
        }
        
        settingsAlert.addAction(reportingAction)
        
    }
    
    
    func settingsAction(_ sender: Any) {
        present(settingsAlert, animated: true)
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
        
        let name = "\(user.firstName!) \(user.lastName!)"
        if user.isPrivate {
            nameLabel.font = UIFont.fontAwesome(ofSize: 17)
            nameLabel.text = name + " " + String.fontAwesomeIcon(name: .lock)
        }else {
            nameLabel.text = name
        }
        
        //Check whether other info is available
        aboutLabel.isHidden = user.about == nil
        locationLabel.isHidden = (user.location == nil && age == nil)
        
        profileHeight = calculateProfileViewHeight()
    }
    
    func updateContactButtons() {
        
        guard followingStatus == .accepted || !user.isPrivate else {
            //if you are not following the user, or they are private then everything should be hidden from this person
            callButton.isHidden = true
            messageButton.isHidden = true
            emailButton.isHidden = true
            faceTimeButton.isHidden = true
            return
        }
    
        callButton.isHidden = user.phone == nil
        messageButton.isHidden = user.phone == nil
        emailButton.isHidden = user.personalEmail == nil
        faceTimeButton.isHidden = user.phone == nil
        tableView.reloadData()
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func calculateProfileViewHeight() -> CGFloat
    {
        let y = statsStackView.frame.origin.y
        return y
    }
    
    func getProfileImage() {
        
        self.profileImageView.image = ProfileImageCreator.create(user.firstName, last: user.lastName)
        
        if user.profileImage == nil {
            if Reachability.isConnectedToInternet() {
                QnClient.sharedInstance.getProfileImageForUser(user: user, began: {imageViewSpinner.isHidden = false
                        imageViewSpinner.startAnimating()
                        }, completion: { (result) in
                            
                            switch result {
                            case .success(let image):
                                self.user.profileImage = image
                                self.profileImageView.image = image
                            case .failure( _):
                                break
                            }
                            
                            self.imageViewSpinner.stopAnimating()
                })
            }
        }else {
            self.profileImageView.image = user.profileImage
        }
    }
    
    //MARK: Functionality
    
    func follow() {
        QnClient.sharedInstance.follow(user: user) { error in
            if let error = error { AlertUtility.showAlertWith(error.localizedDescription)}
        }
    }
    
    func showCancelRequestAlert() {
        
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        let cancelRequestAction = UIAlertAction(title: "Cancel follow request", style: .destructive) { (action) in
            QnClient.sharedInstance.cancelFollow(user: self.user) { error in
            }
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
        
        guard let phoneNumber = user.phone else {
            return
        }
        let phone = "tel://\(phoneNumber)"
        let url = URL(string:phone)!
        UIApplication.shared.openURL(url)
    }
    
    func faceTimeUser() {
        if let phoneNumber = self.user.phone {
            let phone = "facetime://\(phoneNumber)"
            let url = URL(string: phone)!
            UIApplication.shared.openURL(url)
        }
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
    
    func showReportingAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let spamAction = UIAlertAction(title: "It's spam", style: .destructive) { (action) in
            QnClient.sharedInstance.reportUser(user: self.user, type: .spam, completion: { (result) in
                switch result {
                case .failure:
                    RKDropdownAlert.title("We were unable to send your report. Please try again", backgroundColor: .qnRed, textColor: .white)
                case .success:
                     RKDropdownAlert.title("Your report has been sent", backgroundColor: .lightGray, textColor: .white)
                    break
                }
            })
        }
        let inappropriateAction = UIAlertAction(title: "It's inappropriate", style: .destructive) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(spamAction)
        alert.addAction(inappropriateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showUnfollowAction() {
        let alert = UIAlertController(title: user.username, message: nil, preferredStyle: .actionSheet)
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { (action) in
            QnClient.sharedInstance.unfollow(user: self.user) { error in
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(unfollowAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewControllerOtherUser: AccountManagerDelegate {
    func accountManagerUpdated() {
        accountsCollectionView.reloadData()
    }
}

extension ProfileViewControllerOtherUser {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        settingsButton.isEnabled = true
        self.tableView.backgroundView = backgroundView
        self.navigationItem.title = user.username
        
        guard self.isBlocked == false else {
            let empytImage = #imageLiteral(resourceName: "tiki_guy")
            let emptyView = EmptyView(frame: self.view.frame, image: empytImage, titleText: "Bummer", descriptionText: "Looks like that user does not exist")
            
            self.tableView.backgroundView = emptyView
            
            self.navigationItem.title = ""
            self.settingsButton.isEnabled = false
            
            return 0
        }
        
        guard followingStatus == .accepted || !user.isPrivate else {
            //Only show profile view( which is section 1) if your are not following or the user is private
            //Thus hiding accounts and common connections
            return 1
        }
        
        return 3
    }
    
    
}

extension ProfileViewControllerOtherUser: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count != 1 {
            return
        }else {
            navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.0431372549, green: 0.5764705882, blue: 0.1882352941, alpha: 1)
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.tintColor = .white
            

            let cancelButton = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel_button"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(ProfileViewControllerOtherUser.dismissController))
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.titleView?.tintColor = .white
            
        }
    }
}

extension ProfileViewControllerOtherUser: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountManager.numberOfAccounts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let button = accountManager.buttonAt(index: indexPath.row)
//        button.tag = 111
//        
//        if (cell.contentView.viewWithTag(111)) != nil {
//        }else {
//            cell.contentView.addSubview(button)
//        }
        
        cell.contentView.addSubview(button)
        
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
        let _: CGFloat = collectionItemWidth
        
        return CGSize(width: 125.0, height: 75.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

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

