//
//  QnTableViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import RKDropdownAlert
import FirebaseStorage
import ReachabilitySwift



class QnTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: IBOutlets
    
    
    
    
    let kProfileImageBorderWidth:CGFloat = 2.0
    let kProfileImageRadius:CGFloat = 60
    let kHeaderHeight:CGFloat = 40.0
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    
    @IBOutlet weak var firstNameField: UITextField! {
        didSet{self.firstNameField.delegate = self}
    }
    @IBOutlet weak var lastNameField: UITextField! {
        didSet{self.lastNameField.delegate = self}
    }
    @IBOutlet var socialEmailField: UITextField! {
        didSet{self.socialEmailField.delegate = self}
    }
    @IBOutlet var socialPhoneField: UITextField!
    @IBOutlet var firstNameImageView: UIImageView!
    @IBOutlet var lastNameImageView: UIImageView!
    @IBOutlet var twitterLabel: UILabel!
    @IBOutlet var twitterButton: UIButton! {
        didSet {
            self.twitterButton.tag = 0
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    //MARK: Properties
    let tweet = #imageLiteral(resourceName: "tweet")
    
    
    var errorImage = UIImage(named: "error_icon")
    var checkImage = UIImage(named: "check_icon")
    var addTwitterImage = UIImage(named: "add_twitter")
    var twitterAddedImage = UIImage(named:"unlink_twitter")
    let defaultProfileImage = UIImage(named: "default_profile_image")
    
    let imagePicker = UIImagePickerController()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    
    //MARK: IBActions
    
    @IBAction func selectProfileImageAction(_ sender: AnyObject) {
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        saveUser()
    }
    @IBAction func addTwitter(_ sender: AnyObject) {
        
        if self.twitterButton.tag == 0 {
                linkTwitterUser()
        }else {
                unlinkTwitterUser()
            }
        
    }
    
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        NotificationCenter.default.addObserver(self, selector: #selector(QnTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QnTableViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        
        setProfileImageView()
        
        imagePicker.delegate = self
        createPhotoActionSheet()
        
        self.populateFields()
        

        if let profileImage = QnUtilitiy.getProfileImageForCurrentUser() {
            self.profileImageView.image = profileImage
        }else {
//            User.currentUser(completion: { (user) in
//    
//                QnUtilitiy.getProfileImageForUser(user: user, completion: { (image, error) in
//                    self.profileImageView.image = image
//                    
//                    
//                    QnUtilitiy.setProfileImage(image: image!)
//                })
//            })
        }
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    //MARK: UI Methods
    
    func populateFields()
    {
        
        let currentUser = FIRAuth.auth()!.currentUser!
        
        databaseRef.child("users").child(currentUser.uid).observe(.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            
            self.firstNameField.text = user.firstName
            self.lastNameField.text = user.lastName
            
            if let socialEmail = user.socialEmail {
                self.socialEmailField.text = socialEmail
            }
            if let socialPhone = user.socialPhone {
                self.socialPhoneField.text = socialPhone
            }
            if let twitterScreenName = user.twitterScreenName {
                self.twitterLabel.text = "Twitter: \(twitterScreenName)"
                self.twitterButton.tag = 1
                self.twitterButton.setImage(self.twitterAddedImage, for: UIControlState())
            }else{
                self.twitterLabel.text = "Add Twitter Account"
                self.twitterButton.setImage(self.addTwitterImage, for: UIControlState())
                self.twitterButton.tag = 0
            }
        })
        
        
       
        
    }
    
    fileprivate func setProfileImageView()
    {
        profileImageView.layer.borderWidth = kProfileImageBorderWidth
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = kProfileImageRadius
        profileImageView.clipsToBounds = true
        setProfileImage()
        
    }
    
    //MARK: Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        checkTextFields(textField)
        checkToEnableNavButton()
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            socialEmailField.becomeFirstResponder()
        } else {
            socialPhoneField.becomeFirstResponder()
        }
        
        return true
    }
    
    fileprivate func checkTextFields(_ textField:UITextField)
    {
        if textField == firstNameField{
            if textField.text!.utf8.count <= 1 || textField.text!.isEmpty{
                firstNameImageView.image = errorImage
            } else {
                firstNameImageView.image = checkImage
            }
        }
        if textField == lastNameField {
            if textField.text!.utf8.count <= 1 || textField.text!.isEmpty {
                lastNameImageView.image = errorImage
            }else {
                lastNameImageView.image = checkImage
            }
        }
    }
    
    /**
     Checks to make first name and last name are filled before letting user save info
     */
    fileprivate func checkToEnableNavButton()
    {
        let images = [firstNameImageView.image, lastNameImageView.image]
        var count = 0
        for image in images {
            if image == checkImage {
                count += 1
            }
        }
        
        if count == 2 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    
    /**
     Saves current user information for generating QRCode including profile image. Dismissed view controller after.
     */
    
    fileprivate func saveUser()
    {
        QnUtilitiy.updateUserInfo(firstName: firstNameField.text!, lastName: lastNameField.text!, socialEmail: socialEmailField.text, socialPhone: socialPhoneField.text)
        QnUtilitiy.setProfileImage(image: self.profileImageView.image!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Sets fields of user that is passed in
     
     - parameter user: current user passed in
     
     - returns: returns user after fields have been set
     */
    
    fileprivate func createUser(_ user:User) -> User
    {
        user.firstName = firstNameField.text!
        user.lastName = lastNameField.text!
        
        user.socialEmail = socialEmailField.text
        user.socialPhone = socialPhoneField.text
        
        
        return user
    }
    
    /**
     Links user's Twitter Account to QNect account.
     */
    
    fileprivate func linkTwitterUser()
    {
        TwitterUtility().linkTwitterIn(viewController: self) { (error) in
            if error != nil {
                
                RKDropdownAlert.title("Sorry!", message: error!.localizedDescription, backgroundColor: UIColor.qnRed, textColor: UIColor.white)
            }else {
                //User succesfully linked with Twitter
                
                self.populateFields()
            }
        }
      
    }
    
    fileprivate func unlinkTwitterUser()
    {
      TwitterUtility().unlinkTwitter { (error) in
        if error  != nil {
            RKDropdownAlert.title("Oops", message: error!.localizedDescription, backgroundColor: UIColor.qnRed, textColor: UIColor.white)
            }
        }
    }
    
    
    
    //MARK: TableView DelegateFunctions

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    
    //MARK: Keyboard Functions
    
    func keyboardWillShow(_ notification:Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + keyboardSize.height/2 , right: 0)
            
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        let rate = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        UIView.animate(withDuration: rate.doubleValue, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero;
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero;
        })
    }
    
    //MARK: Image Picker Controller Methods
    
    fileprivate func selectProfileImage()
    {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.navigationBar.barTintColor = UIColor.qnBlue
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        imagePicker.navigationBar.tintColor = UIColor.white
        present(imagePicker, animated: true, completion: {UIApplication.shared.statusBarStyle = .lightContent})
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    //MARK: Action Sheet Methods
    fileprivate func createPhotoActionSheet()
    {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        let removePhotoAction = UIAlertAction(title: "Remove Current Photo", style: .destructive) { (action) -> Void in
            self.setProfileImage()
        }
        
        let addPhotoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) -> Void in
            self.selectProfileImage()
            
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(removePhotoAction)
        actionSheet.addAction(addPhotoAction)
    }
    
    fileprivate func setProfileImage()
    {
        
    }    
    
}
