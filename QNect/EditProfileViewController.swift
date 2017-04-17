//
//  ProfileInfoTableViewController.swift
//  
//
//  Created by Panucci, Julian R on 3/8/17.
//
//

import UIKit
import SkyFloatingLabelTextField
import IQKeyboardManagerSwift
import RSKImageCropper

class EditProfileViewController: UITableViewController {

    //MARK: Properties
    
    var userInfo: UserInfo?
    var edittingInfo = false
    override var prefersStatusBarHidden: Bool {
        return true
    }
    let imagePicker = UIImagePickerController()
    var continueButton: UIBarButtonItem! {
        didSet {
            continueButton.isEnabled = false
            continueButton.tintColor = .clear
        }
    }
    var saveButton: UIBarButtonItem!
   
    //MARK: Outlets
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextField! {
        didSet {
            emailField.delegate = self
        }
    }
    @IBOutlet weak var phoneField: SkyFloatingLabelTextField! {
        didSet {
            phoneField.delegate = self
        }
    }
    @IBOutlet weak var profileImageView: ProfileImageView! {
        didSet {
            profileImageView.backgroundColor = UIColor.clear
            profileImageView.layer.cornerRadius = 50.0
            profileImageView.layer.borderColor = UIColor.qnPurple.cgColor
            profileImageView.layer.borderWidth  = 2.0
            profileImageView.layer.masksToBounds = true
        }
    }
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var continueAndSaveButton: UIBarButtonItem!
    
    //MARK: Actions
    
    @IBAction func skipAction(_ sender: Any) {
        skip()
    }
   
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(EditProfileViewController.saveInfo))
        continueButton = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(EditProfileViewController.continueSignup))
    
        
        #if UI
            self.userInfo = UserInfo.testUser
        #endif
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        
        if let userInfo = userInfo {
            self.profileImageView.image = ProfileImageCreator.create(userInfo.firstName!, last: userInfo.lastName!)
        }else {
            self.profileImageView.image = QnClient.sharedInstance.getProfileImageForCurrentUser()
        }
        profileImageView.onClick = {
            self.editProfileImage()
        }
        
        self.tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        imagePicker.delegate = self
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        setupViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.qnPurple
    }
    
    
    //MARK: Setup
    
    func setupViewController() {
        if edittingInfo {
            titleLabel.text = "Edit Profile"
            descriptionLabel.isHidden = true
            skipButton.isEnabled = false
            skipButton.tintColor = UIColor.clear
           
            navigationItem.rightBarButtonItem = saveButton
            //todo: Populate fields for what they have already entered
        }else {
            titleLabel.text = "Profile Info"
            descriptionLabel.isHidden = false
            skipButton.isEnabled = true
            skipButton.tintColor = UIColor.qnPurple
            navigationItem.leftBarButtonItem = skipButton
            navigationItem.rightBarButtonItem = continueButton
        }
    }
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    
    func configureViewController(edittingInfo: Bool) {
        //If the user has already signed up then they can edit their info in this controller as well, so editting info will be true
        
        //If the user is signing up and is the first time on this screen edittign info will be false
        
        self.edittingInfo = edittingInfo
    }
    
    //MARK: Functionality
    func saveInfo() {
        //todo: Save and update user info
        print("Saving user info...")
        dismiss(animated: true, completion: nil)
    }
    
    func continueSignup()
    {
        //todo: Include location, about, age, etc
        //Should we check for internet connection??
        QnClient.sharedInstance.updateUserInfo(socialEmail: emailField.text, socialPhone: phoneField.text)
        QnClient.sharedInstance.setProfileImage(image: profileImageView.image!)
        
        performSegue(withIdentifier: "LinkAccounts", sender: self)
    }
    
    func skip()
    {
        //Setting the image either way
        QnClient.sharedInstance.setProfileImage(image: profileImageView.image!)
        performSegue(withIdentifier: "LinkAccounts", sender: self)
        
    }
    
    //MARK: User Interaction
    
    func editProfileImage()
    {
        let alert = UIAlertController(title: "Edit Profile Image", message: nil, preferredStyle: .actionSheet)
        
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
            self.profileImageView.image = ProfileImageCreator.create(self.userInfo!.firstName!, last: self.userInfo!.lastName!)
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
    
    //MARK: Helper Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
    }
    
}



extension EditProfileViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard textField == emailField else {
            continueSignup()
            return true
        }
        
        phoneField.becomeFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard textField.text != nil else {
            continueButton.isEnabled = false
            continueButton.tintColor = UIColor.clear
            return true
        }
        
        continueButton.isEnabled = true
        continueButton.tintColor = UIColor.qnPurple
        return true
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditProfileViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
    
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}


