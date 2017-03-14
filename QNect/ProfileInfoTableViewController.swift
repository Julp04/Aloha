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

class ProfileInfoTableViewController: UITableViewController {

    //MARK: Properties
    
    var userInfo: UserInfo?
    let imagePicker = UIImagePickerController()
   
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
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.backgroundColor = UIColor.clear
            profileImageView.layer.cornerRadius = 50.0
            profileImageView.layer.borderColor = UIColor.qnPurple.cgColor
            profileImageView.layer.borderWidth  = 2.0
            profileImageView.layer.masksToBounds = true
        }
    }
    
    //MARK: Actions
    
    @IBAction func addProfileImage(_ sender: Any) {
        addProfileImage()
    }
   
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        self.profileImageView.image = ProfileImage.createProfileImage(userInfo!.firstName!, last: userInfo!.lastName!)
        
        self.tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        imagePicker.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    //MARK: Functionality
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    
    func continueSignup()
    {
        //todo: Might add more fields
        //Should we check for internet connection??
        QnUtilitiy.updateUserInfo(socialEmail: emailField.text, socialPhone: phoneField.text)
    }
    
    //MARK: User Interaction
    
    func addProfileImage()
    {
    
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
            self.profileImageView.image = ProfileImage.createProfileImage(self.userInfo!.firstName!, last: self.userInfo!.lastName!)
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

extension ProfileInfoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension ProfileInfoTableViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard textField == emailField else {
            continueSignup()
            return true
        }
        
        phoneField.becomeFirstResponder()
        return true
    }
}

extension ProfileInfoTableViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
    
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}
