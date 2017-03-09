//
//  Signup1ViewController.swift
//  QNect
//
//  Created by Panucci, Julian R on 2/24/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RSKImageCropper



class Signup1ViewController: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate{

    @IBOutlet weak var emailField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.emailField.delegate = self
            emailField.iconFont = UIFont.fontAwesome(ofSize: 15)
            emailField.iconText = "\u{f007}"
            emailField.title = "Email"
            emailField.titleColor = UIColor.lightGray
            emailField.selectedTitleColor = UIColor.qnPurple
            emailField.iconMarginBottom = -2.0
            
            
        }
    }
   
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon! {
        didSet {
            self.passwordField.delegate = self
            self.passwordField.iconFont = UIFont.fontAwesome(ofSize: 15)
            self.passwordField.iconText = "\u{f023}"
            passwordField.iconMarginBottom = -2.0
            
            
        }
    }
    @IBOutlet weak var continueButton: UIButton! {
        didSet{
            continueButton.layer.cornerRadius = 5.0
            continueButton.backgroundColor = UIColor.qnPurple
            changeContinueStatus(enabled: false)
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
    
    @IBAction func addPhotoAction(_ sender: Any) {
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
            self.profileImageView.image = nil
            self.addPhotoButton.titleLabel?.text = "Add Photo"
            
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
    
    @IBOutlet weak var addPhotoButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func continueToNextStep()
    {
        
    }
    
    func changeContinueStatus(enabled:Bool)
    {
        continueButton.isEnabled = enabled
        continueButton.alpha = enabled ? 1.0: 0.5
        
    }
    
    
    //MARK: TextField Delegate
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            self.passwordField.becomeFirstResponder()
        }else {
            continueToNextStep()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            if let email = emailField.text {
                if !email.contains("@") {
                        emailField.errorMessage = "Invalid Email"
                }else {
                    emailField.errorMessage = ""
                }
            }
        }
        
        if textField == passwordField {
            if let password = passwordField.text {
                if password.characters.count < 5 {
                    passwordField.errorMessage = "Must be more than 6 characters"
                }else {
                    passwordField.errorMessage = ""
                    
                }
            }
        }
        
        if (passwordField.text?.characters.count)! >= 5 && (emailField.text?.contains("@"))! {
            changeContinueStatus(enabled: true)
        }else {
            changeContinueStatus(enabled: false)
        }
        
    
        
        
        
        return true
    }
    
    
    //MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = image
        addPhotoButton.titleLabel?.text = ""
        
        let imageCropper = RSKImageCropViewController(image: image, cropMode: .circle)
        imageCropper.delegate = self
        
        dismiss(animated: true, completion: nil)
        self.present(imageCropper, animated: true, completion: nil)
        
       
        
        
//        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Image Cropper
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        controller.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
        
    }
    
    
    

    

}
