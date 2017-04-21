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
    var connectionsHeaderTitle: String!
    
    var profileHeight: CGFloat = 0.0
    let imagePicker = UIImagePickerController()
    var twitterButton: SwitchButton?
    
   
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
    
    
    //MARK: Configure Before Load
    
    
    func configureViewController(displayCurrentUserProfile: Bool, user: User)
    {
        self.user = user
//        user.about = "I am cool"
        user.location = "Pittsburgh, PA"
        user.birthdate = "10-09-1993"
    }
    
    
    fileprivate func setUpViewController() {
        //Setup view controller as if we were viewing someone else's profile
        //Ex: Follow button would be displayed, we could see call, message, email buttons (only if user had those), Show common connections with current user, Accounts button would change so you could follow or add the contact
        
        callButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.callUser), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.messageUser), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.emailUser), for: .touchUpInside)
        
        callButton.isHidden = user.socialPhone == nil
        messageButton.isHidden = user.socialPhone == nil
        emailButton.isHidden = user.socialEmail == nil
        
        //Follow button instead of editProfile button
        configureFollowButton()
        
        connectionsHeaderTitle = "Common Connections"
        
        //Set profile image
        setProfileImage()
    
    }
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
        
        createAccountsButtons()
        
        
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
        
        
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
    
    func createAccountsButtons() {
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 125.0, height: 75.0)
        if let twitterScreenName = user.twitterAccount?.screenName {
            //User linked with twitter
           
        }
    }
    
    func calculateProfileViewHeight() -> CGFloat
    {
        let y = statsStackView.frame.origin.y
        let finalPosition = y
        
        return finalPosition
    }
    
    func configureFollowButton() {
        //todo: Check whether current user is following displayed user
        let isFollowing = false
        let buttonText = isFollowing ? "Following" : "Follow"
        
        followOrEditProfileButton.setTitle(buttonText, for: .normal)
        followOrEditProfileButton.addTarget(self, action: #selector(ProfileViewControllerOtherUser.follow), for: .touchUpInside)
    }
    
    func setProfileImage() {
        
        if user.profileImage == nil {
            if Reachability.isConnectedToInternet() {
                QnClient.sharedInstance.getProfileImageForUser(user: user, completion: { (profileImage, error) in
                    if error != nil {
                        print(error!)
                    }else {
                        self.profileImageView.image = profileImage
                    }
                })
            }
        }else {
            self.profileImageView.image = user.profileImage
        }
    }
    
    //MARK: Functionality
    
    func editProfile() {
        weak var editProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
        editProfileViewController?.configureViewController(edittingInfo: true)
        
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "OnboardNavController") as! UINavigationController
        navigationController.setViewControllers([editProfileViewController!], animated: true)


        //todo: Custom transition, status bar should be black
        
        //Fixes memory warning
        self.view.window?.rootViewController?.present(navigationController, animated: true)

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
    
    func follow() {
    
    }
    
    func messageUser() {
        
    }
    
    func callUser() {
        
    }
    
    func emailUser() {
        
    }
}

extension ProfileViewControllerOtherUser: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
       
        if indexPath.row == 0 {
            
            if let twitterButton = twitterButton {
                cell.contentView.addSubview(twitterButton)
            }
        }
        
        cell.backgroundColor = UIColor.brown
        
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

extension ProfileViewControllerOtherUser: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension ProfileViewControllerOtherUser: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}
