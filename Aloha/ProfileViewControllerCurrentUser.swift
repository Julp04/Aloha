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

enum CollectionType:Int {
    case accounts = 0
    case recentlyAdded = 1
}

extension UICollectionView {
    
    var collectionType: CollectionType {
        get {
            return CollectionType(rawValue: tag)!
        }
    }
}

class ProfileViewControllerCurrentUser: UITableViewController {
    
    //MARK: Constants
    let kAccountsHeaderTitle = "Accounts"
    let kHeaderHeight: CGFloat = 30.0
    let kHeaderFontSize: CGFloat = 13.0
    let kHeaderFontName = "Futura"
    let kNavigationBarHeight: CGFloat = 64
    
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 10
    let collectionRightInset: CGFloat = 10
    
    
    //MARK: Properties
    var displayCurrentUserProfile = true
    var user: User!
    var connectionsHeaderTitle: String!
    
    var profileHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var accountManager: CurrentUserAccountManager!
    
    var followRequests = [User]()
    var recentlyAddedUsers = [User]()
    var client = QnClient()
    
    var usernames = [String: [Any]]()
    
    
   
    //MARK: Outlets
    @IBOutlet weak var followRequestImageView: ProfileImageView!
    @IBOutlet weak var imageViewSpinner: UIActivityIndicatorView!
    @IBOutlet weak var requestBlipView: UIView!
    @IBOutlet weak var requestsCountLabel: UILabel!
  
    @IBOutlet var descriptionLabels: [UILabel]!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var scansLabel: UILabel!
    
    @IBOutlet weak var scansView: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
   
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var followOrEditProfileButton: JPLoadingButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var statsStackView: UIStackView!
    
    @IBOutlet weak var recentlyAddedCollectionView: UICollectionView!
    @IBOutlet weak var accountsCollectionView: UICollectionView!
    //MARK: Actions
    
  
    //MARK: Configure Before Load
    
    
    func configureViewController(currentUser: User)
    {
        self.user = currentUser
        accountManager = CurrentUserAccountManager(user: user, viewController: self)
    }
    
    func setupViewController() {
        //Setup view controller only if we were to view as ourself
        //Ex: Follow button would be EditProfileButton, Common Connections would be Recent Added Connections, Won't show call, message, email buttons, Accounts buttons would link your accounts to your profile
       
        navigationController?.navigationBar.topItem?.title = user.username
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
        
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        //Cannot email, message, or call self...
        callButton.isHidden = true
        messageButton.isHidden = true
        emailButton.isHidden = true
        
        //Edit profile button instead of follow button
        followOrEditProfileButton.setTitle("Edit Profile", for: .normal)
        followOrEditProfileButton.addTarget(self, action: #selector(ProfileViewControllerCurrentUser.editProfile), for: .touchUpInside)
        
        connectionsHeaderTitle = "Recently Added"
        
        //ProfileImageView
        imagePicker.delegate = self
        
        profileHeight = calculateProfileViewHeight()
        
        //tod
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabels.forEach { (label) in
            label.textColor = UIColor.gray
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        setupViewController()
        updateUI()
        
        
        client.getFollowers { (followers) in
            DispatchQueue.main.async {
                self.followersLabel.text = "\(followers.count)"
            }
        }
        
        client.getFollowing { (following) in
            DispatchQueue.main.async {
                self.followingLabel.text = "\(following.count)"
            }
        }
        
        client.getRecentlyAdded { (users) in
            DispatchQueue.main.async {
                self.recentlyAddedUsers = users
                self.recentlyAddedCollectionView.reloadData()
                
                
            }
        }
        
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
        accountsCollectionView.tag = 0
        
        recentlyAddedCollectionView.dataSource = self
        recentlyAddedCollectionView.delegate = self
        recentlyAddedCollectionView.tag = 1
        
        let followersTappedGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewControllerCurrentUser.followersViewTapped))
        let followingTappedGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewControllerCurrentUser.followingViewTapped))
        let scansTappedGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewControllerCurrentUser.scansViewTapped))
        
        followersView.addGestureRecognizer(followersTappedGesture)
        followingView.addGestureRecognizer(followingTappedGesture)
        scansView.addGestureRecognizer(scansTappedGesture)
        
        requestBlipView.layer.cornerRadius = requestBlipView.bounds.width / 2.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageViewSpinner.isHidden = true
        
        navigationController?.navigationBar.barTintColor =  UIColor.alohaOrange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.topItem?.titleView = nil
        navigationController?.navigationBar.topItem?.title = user.username
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.delegate = self
        
        client.getUpdatedInfoForUser(user: user) { (user) in
            self.user = user
            self.updateUI()
        }
        
        client.getProfileImageForUser(user: user, began: {
            imageViewSpinner.isHidden = false
            imageViewSpinner.startAnimating()}) { (result) in
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.user.profileImage = image
                        self.profileImageView.image = image
                    case .failure(_):
                        break
                    }
                    
                    self.imageViewSpinner.stopAnimating()
                }
        }
        
        client.getFollowRequests { (followRequests) in
            let oldRequests = self.followRequests.count
            let newRequests = followRequests.count
            
            self.followRequests = followRequests
            
            DispatchQueue.main.async {
                if newRequests > 0 {
                   
                    let firstRequest = followRequests[0]
                    self.followRequestImageView.image = ProfileImageCreator.create(firstRequest.firstName, last: firstRequest.lastName)
                    ImageDownloader.downloadImage(url: firstRequest.profileImageURL, completion: { (result) in
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                self.followRequestImageView.image = image
                            }
                        case .failure(let _):
                            break
                        }
                    })
                    self.requestsCountLabel.text = "\(newRequests)"
                    self.tableView.allowsSelection = true
                }else {
                    self.tableView.allowsSelection = false
                }
                self.tableView.reloadData()
                
                if newRequests > oldRequests {
                    let indexPath = IndexPath(row: 1, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.right)
                }
            }
        }
        
        accountManager.update(user: user)
        accountsCollectionView.reloadData()
    }
    
    func followersViewTapped() {
        
        let followersController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        followersController.configureViewController(type: .followers)
        
        self.navigationController?.pushViewController(followersController, animated: true)
    }
    
    func followingViewTapped() {
        let followersController = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        followersController.configureViewController(type: .following)
        
        self.navigationController?.pushViewController(followersController, animated: true)
    }
    
    func scansViewTapped() {
        
    }
    
    
    
    func updateUI() {
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
    }
    
 
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            if indexPath.row == 1 {
                return 66
            }
            //todo: calculate this height better
            
            return calculateProfileViewHeight() + kNavigationBarHeight
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if followRequests.isEmpty {
                return 1
            }else {
                return 2
            }
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            //Selected follow requests cell
            let followRequestsViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowRequestsViewController") as! FollowRequestsViewController
            followRequestsViewController.configureViewController(requests: followRequests)
            
            navigationController?.pushViewController(followRequestsViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: UI Helper

    
    func calculateProfileViewHeight() -> CGFloat
    {
        return statsStackView.frame.origin.y
    }
    
    //MARK: Functionality
    
    func editProfile() {
        
        let editProfileNavController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileInfoNavController") as! UINavigationController
        let editProfileInfoViewController = editProfileNavController.viewControllers.first as! EditProfileInfoViewController
        editProfileInfoViewController.configureViewController(currentUser: self.user, listener: self)
        
        self.present(editProfileNavController, animated: true, completion: nil)
    }
    
    func editProfileImage() {
        let alert = UIAlertController(title: "Add Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        let selfieAction = UIAlertAction(title: "Take Selfie", style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.imagePicker.navigationBar.barTintColor = UIColor.qnBlue
            self.imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            self.imagePicker.navigationBar.tintColor = UIColor.white
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.navigationBar.barTintColor = UIColor.qnBlue
            self.imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            self.imagePicker.navigationBar.tintColor = UIColor.white
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: .destructive) { (action) in
            self.profileImageView.image = ProfileImageCreator.create(self.user.firstName!, last: self.user.lastName!)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(selfieAction)
        }
        
        if self.profileImageView.image != nil {
            alert.addAction(removePhotoAction)
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewControllerCurrentUser: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.collectionType {
        case .accounts:
            return accountManager.numberOfAccounts()
        case .recentlyAdded:
            return recentlyAddedUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.collectionType {
        case .accounts:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountCell", for: indexPath)
            
            let button = accountManager.buttonAt(index: indexPath.row)
            button.tag = 111
            
            if (cell.contentView.viewWithTag(111)) != nil {
            }else {
                cell.contentView.addSubview(button)
            }
            
            return cell
        case .recentlyAdded:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectionCell", for: indexPath)
            
            let user = recentlyAddedUsers[indexPath.row]
            let profileImageView = ProfileImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            let tmpImg = ProfileImageCreator.create(user.firstName, last: user.lastName)
            profileImageView.image = tmpImg
            profileImageView.onClick = {
                let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewControllerOtherUser") as! ProfileViewControllerOtherUser
                profileViewController.configureViewController(user: user)
                self.navigationController?.pushViewController(profileViewController, animated: true)
            }
            
            
            cell.contentView.addSubview(profileImageView)
            if user.profileImage == nil {
                client.getProfileImageForUser(user: user, began: {
                }, completion: { (result) in
                    switch result {
                    case .success(let image):
                        user.profileImage = image
                        profileImageView.image = image
                    default:
                         user.profileImage = tmpImg
                        break
                    }
                    
                  
                    
                    let imageData = UIImagePNGRepresentation(user.profileImage!)
            
                    
                    if self.usernames["username"]?.append(user.username) == nil{
                       self.usernames["username"] = [user.username]
                    }
                    
                    if self.usernames["imageData"]?.append(imageData!) == nil {
                        self.usernames["imageData"] = [imageData!]
                    }
                    if self.usernames["uid"]?.append(user.uid) == nil {
                        self.usernames["uid"] = [user.uid]
                    }
                    
                    let userDefaults = UserDefaults(suiteName: "group.io.sayaloha.aloha")
                    userDefaults!.set(self.usernames, forKey: "recentlyAdded")
                    
                    userDefaults!.synchronize()
                    
                    
                    DispatchQueue.main.async {
                        cell.contentView.addSubview(profileImageView)
                    }
                })
            }
            return cell
        }
        
      
    }

    
}

extension ProfileViewControllerCurrentUser: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch collectionView.collectionType {
        case .accounts:
            return UIEdgeInsetsMake(collectionTopInset, collectionLeftInset, collectionBottomInset, collectionRightInset)
        case .recentlyAdded:
            return UIEdgeInsetsMake(collectionTopInset, collectionLeftInset, collectionBottomInset, collectionRightInset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.collectionType {
        case .accounts:
            return CGSize(width: 125.0, height: 75.0)
        
        case .recentlyAdded:
//            let tableViewCellHeight: CGFloat = tableView.rowHeight
//            let collectionItemWidth: CGFloat = tableViewCellHeight - (collectionLeftInset + collectionRightInset)
//            let _: CGFloat = collectionItemWidth
            return CGSize(width: 80, height: 75.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

extension ProfileViewControllerCurrentUser: UICollectionViewDelegate {
    
}

extension ProfileViewControllerCurrentUser: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = image
        
        let imageCropper = RSKImageCropViewController(image: image, cropMode: .circle)
        imageCropper.delegate = self
        
        imagePicker.present(imageCropper, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewControllerCurrentUser: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}

extension ProfileViewControllerCurrentUser: PresentedControllerListener {
    func presentedControllerDismissed() {
        //When EditProfileViewController dismisses and info is saved call this function to repopulate profile controller
        setupViewController()
    }
}

