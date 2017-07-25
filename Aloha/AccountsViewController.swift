//
//  AccountsViewController.swift
//  
//
//  Created by Panucci, Julian R on 3/17/17.
//
//

import UIKit
import LTMorphingLabel
import Social
import Accounts
import RKDropdownAlert
import FCAlertView


class AccountsViewController: UIViewController {
    
    //MARK: Constants
    
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 2.5
    let collectionRightInset: CGFloat = 2.5
    let kMaxRows:CGFloat = 2.0

    //MARK: Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var accountManager: AccountManager!
    
    //MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Actions
    
    @IBAction func continueAction(_ sender: Any) {
        isCameraAuthorized()
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountManager = AccountManager(viewController: self)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    //MARK: Functionality
    
    func calculateWidth(row: Int) -> CGFloat {
        var width = collectionView.bounds.size.width - collectionRightInset - collectionLeftInset
        
        if accountManager.numberOfAccounts() % 2 != 0 {
            if row == accountManager.numberOfAccounts() - 1 {
                return width
            }
        }else{
            if accountManager.numberOfAccounts() == 2 {
                return width
            }
        }
        width = width / kMaxRows - collectionLeftInset - collectionRightInset
        return width
    }
    
    func calculateHeight() -> Int {
        return 100
    }
    
    func isCameraAuthorized() {
        
        if Platform.isSimulator {
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
            self.present(mainVC, animated: true, completion: nil)
       
        } else {
            let cameraMediaType = AVMediaTypeVideo
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
            
            switch cameraAuthorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
                    self.present(mainVC, animated: true, completion: nil)
                }
               
            case .notDetermined, .restricted, .denied:
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                    if granted {
                        self.isCameraAuthorized()
                    }else {
                        let accessCameraController = self.storyboard?.instantiateViewController(withIdentifier: "AccessCameraController") as! AccessCameraController
                        
                        self.present(accessCameraController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension AccountsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountManager.numberOfAccounts();
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = calculateWidth(row: indexPath.row)
        let height = calculateHeight()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        let buttonFrame = CGRect(x: 0, y: 0, width: Int(width), height: height)
        
        let button = accountManager.buttonAt(index: indexPath.row, frame: buttonFrame)
        cell.contentView.addSubview(button)
        
        return cell
    }
    
}

extension AccountsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionTopInset, collectionLeftInset, collectionBottomInset, collectionRightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calculateWidth(row: indexPath.row)
        let height = calculateHeight()
        
        return CGSize(width: width, height: CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
















