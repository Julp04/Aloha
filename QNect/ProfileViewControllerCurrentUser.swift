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



class ProfileViewControllerCurrentUser: UITableViewController {
    
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
    var displayCurrentUserProfile = true
    var user: User!
    var connectionsHeaderTitle: String!
    
    var profileHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var profileManager: ProfileManager!
    
   
    //MARK: Outlets
  
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var scansLabel: UILabel!
    
    
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
    
    
    //MARK: Configure Before Load
    
    
    func configureViewController(currentUser: User)
    {
        self.user = currentUser
        profileManager = ProfileManager(currentUser: currentUser, viewController: self)
    }
    
    func setupViewController() {
        //Setup view controller only if we were to view as ourself
        //Ex: Follow button would be EditProfileButton, Common Connections would be Recent Added Connections, Won't show call, message, email buttons, Accounts buttons would link your accounts to your profile
       
        navigationController?.navigationBar.topItem?.title = user.username
        
        tableView.backgroundColor = .clear
        
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
        
        let profileImage = QnClient.sharedInstance.getProfileImageForCurrentUser()
        profileImageView.image = profileImage
        
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
        
        QnClient.sharedInstance.getFollowing { (users) in
            self.followingLabel.text = "\(users.count)"
        }
        
        QnClient.sharedInstance.getFollowers { (users) in
            self.followersLabel.text = "\(users.count)"
        }
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Disable transition manager so we cannot transition to code view controllwer when we hold on buttons and swipe 
        //bug i was having (this might be temp fix ?? 😜
        let mainController = self.parent?.parent?.parent as! MainController
        mainController.transitionManager.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Enable the transition manager when we leave this view controler
        let mainController = self.parent?.parent?.parent as! MainController
        mainController.transitionManager.isEnabled = true
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //MARK: UI Helper

    
    func calculateProfileViewHeight() -> CGFloat
    {
        let y = statsStackView.frame.origin.y
        let finalPosition = y
        
        return finalPosition
    }
    
    //MARK: Functionality
    
    func editProfile() {
        
       //todo: EditProfile
        
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

extension ProfileViewControllerCurrentUser: UICollectionViewDelegateFlowLayout {
    
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

