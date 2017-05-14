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

class AddProfileInfoViewController: UITableViewController {

    //MARK: Properties
    
    var userInfo: UserInfo?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    let imagePicker = UIImagePickerController()
    var saveButton: UIBarButtonItem!
    var datePicker = UIDatePicker()
   
    //MARK: Outlets
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneField: SkyFloatingLabelTextField!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var locationField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthdateField: SkyFloatingLabelTextField!
    @IBOutlet weak var aboutField: UITextView!
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIBarButtonItem!
    //MARK: Actions
   
    @IBAction func continueAction(_ sender: Any) {
        continueSignup()
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        
        if let userInfo = userInfo {
            self.profileImageView.image = ProfileImageCreator.create(userInfo.firstName!, last: userInfo.lastName!)
        }
        profileImageView.onClick = {
            self.editProfileImage()
        }
        
        self.tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        imagePicker.delegate = self
        emailField.delegate = self
        locationField.delegate = self
        birthdateField.delegate = self
        phoneField.delegate = self
        aboutField.delegate = self
        aboutField.textColor = .gray
        
        
        birthdateField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(AddProfileInfoViewController.datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        if let birthdate = birthdateField.text?.asDate() {
            datePicker.date = birthdate
        }
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        
      
        super.viewWillAppear(true)
    }
    
    
    //MARK: Setup
    
    func configureViewController(userInfo:UserInfo)
    {
        self.userInfo = userInfo
    }
    
    
    func continueSignup()
    {

        QnClient.sharedInstance.updateUserInfo(firstName: userInfo!.firstName!, lastName: userInfo!.lastName!, personalEmail: emailField.text!, phone: phoneField.text!, location: locationField.text!, birthdate: birthdateField.text!, about: aboutField.text!)
        
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
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        alert.addAction(removePhotoAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let date = sender.date
        birthdateField.text = date.asString()
    }
    
    //MARK: Helper Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension AddProfileInfoViewController: UITextViewDelegate {
    
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
            continueButton.isEnabled = false
            continueButton.tintColor = .clear
            textView.textColor = .qnRed
        }else {
            textView.textColor = .black
            continueButton.isEnabled = true
            continueButton.tintColor = .qnPurple
        }
    }
}

extension AddProfileInfoViewController: UITextFieldDelegate {

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}

extension AddProfileInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension AddProfileInfoViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
    
        controller.dismiss(animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
        profileImageView.image = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
}




