//
//  EditProfileInfoViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/26/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RSKImageCropper

class EditProfileInfoViewController: UITableViewController {
    
    //MARK: Constants
    
    //MARK: Properties
    
    var currentUser: User!
    let imagePicker = UIImagePickerController()
    
    //MARK: Outlets
    
    @IBOutlet weak var locationField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var lastNameField: SkyFloatingLabelTextField!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneField: SkyFloatingLabelTextField!
    
    //MARK: Actions
    
    @IBAction func saveAction(_ sender: Any) {
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        imagePicker.delegate = self
        profileImageView.onClick = {
            self.editProfileImage()
        }
        profileImageView.borderColor = .qnPurple
      
        
    }
    
    func configureViewController(currentUser: User) {
        self.currentUser = currentUser
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
            self.profileImageView.image = ProfileImageCreator.create(self.currentUser.firstName, last: self.currentUser.lastName)
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



extension EditProfileInfoViewController: UITextFieldDelegate {
    

    
}


extension EditProfileInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditProfileInfoViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}
