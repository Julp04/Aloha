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
import Crashlytics

protocol PresentedControllerListener {
    func presentedControllerDismissed()
}

class EditProfileInfoViewController: UITableViewController {
    
    //MARK: Constants
    
    //MARK: Properties
    
    var currentUser: User!
    let imagePicker = UIImagePickerController()
    private var listener: PresentedControllerListener?
    var datePicker = UIDatePicker()
    
    //MARK: Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var locationField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var lastNameField: SkyFloatingLabelTextField!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthdateField: SkyFloatingLabelTextField!
    @IBOutlet weak var aboutField: UITextView!
    
    //MARK: Actions
    
    
    @IBAction func saveAction(_ sender: Any) {
        saveInfo()
    }
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        loadUserInfo()
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        imagePicker.delegate = self
        profileImageView.onClick = {
            self.editProfileImage()
        }
        profileImageView.borderColor = .main
        
        //Textview delegate setup
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        locationField.delegate = self
        
        birthdateField.delegate = self
        birthdateField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(EditProfileInfoViewController.datePickerValueChanged(sender:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        if let birthdate = birthdateField.text?.asDate() {
            datePicker.date = birthdate
        }
        
        aboutField.delegate = self
        
        firstNameField.textColor = .main
        firstNameField.selectedLineColor = .main
        firstNameField.selectedTitleColor = .main
        
        lastNameField.textColor = .main
        lastNameField.selectedTitleColor = .main
        lastNameField.selectedLineColor = .main
        
        emailField.textColor = .main
        emailField.selectedLineColor = .main
        emailField.selectedTitleColor = .main
        
        phoneField.textColor = .main
        phoneField.selectedTitleColor = .main
        phoneField.selectedLineColor = .main
        
        locationField.textColor = .main
        locationField.selectedTitleColor = .main
        locationField.selectedLineColor = .main
        
        birthdateField.textColor = .main
        birthdateField.selectedLineColor = .main
        birthdateField.selectedTitleColor = .main
        
        navigationController?.navigationBar.tintColor = .main
    }
    
    func configureViewController(currentUser: User, listener: PresentedControllerListener) {
        self.currentUser = currentUser
        self.listener = listener
    }
    
    
    //MARK: Setup
    
    func loadUserInfo() {
        firstNameField.text = currentUser.firstName
        lastNameField.text = currentUser.lastName
        
        emailField.text = (currentUser.personalEmail != nil) ? currentUser.personalEmail! : nil
        phoneField.text = (currentUser.phone != nil) ? currentUser.phone! : nil
        locationField.text = (currentUser.location != nil) ? currentUser.location! : nil
        birthdateField.text = (currentUser.birthdate != nil) ? currentUser.birthdate! : nil
        
        aboutField.text = (currentUser.about != nil) ? currentUser.about! : "About"
        aboutField.textColor = aboutField.text == "About" ? .lightGray : .black
        
        //Get profile image of user
        QnClient.sharedInstance.getProfileImageForUser(user: currentUser, began: {}) { (result) in
            switch result {
            case .success(let image):
                self.profileImageView.image = image
                self.currentUser.profileImage = image
            case .failure( _):
                break
            }
        }
        
        
    }
    
    //MARK: Functionality
    
    func saveInfo () {
        //save all profile info and images
        
        QnClient.sharedInstance.updateUserInfo(firstName: firstNameField.text!, lastName: lastNameField.text!, personalEmail: emailField.text, phone: phoneField.text, location: locationField.text, birthdate: birthdateField.text, about: aboutField.text)
        
        QnClient.sharedInstance.setProfileImage(image: profileImageView.image!)
        
        dismiss(animated: true) {
            self.listener?.presentedControllerDismissed()
        }
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        birthdateField.text = date.asString()
    }
    
    
    //MARK: User Interaction
    
    func editProfileImage()
    {
        let alert = UIAlertController(title: "Edit Profile Image", message: nil, preferredStyle: .actionSheet)
        
        let selfieAction = UIAlertAction(title: "Camera", style: .default) { (action) in
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
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        alert.addAction(removePhotoAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditProfileInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "About" {
            textView.textColor = .black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            textView.text = "About"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count > 50 {
            saveButton.isEnabled = false
            saveButton.tintColor = .clear
            textView.textColor = .qnRed
        }else {
            textView.textColor = .black
            saveButton.isEnabled = true
            saveButton.tintColor = .main
        }
    }
}


extension EditProfileInfoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard (firstNameField.text?.characters.count)! >= 3 && (lastNameField.text?.characters.count)! >= 3 else {
            self.saveButton.isEnabled = false
            self.saveButton.tintColor = .clear
            return true
        }
        
        saveButton.isEnabled = true
        saveButton.tintColor = .main
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            lastNameField.becomeFirstResponder()
        case lastNameField:
            emailField.becomeFirstResponder()
        default:
            break
        }
        
        return true
    }

    
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




