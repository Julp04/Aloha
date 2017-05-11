//
//  ConnectionsViewController.swift
//  QNect
//
//  Created by Julian Panucci on 11/13/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import ReachabilitySwift
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import RKDropdownAlert

class ConnectionsViewController: UITableViewController {

    
    //MARK: Constants
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    
    //MARK: Properties
    
    var following = ConnectionsModel(connections: [User]())
    var selectedConnection: User?
    
    //MARK: Outlets
    
    //MARK: Actions
    
    //MARK: Lifecycle
    
   
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    
    //MARK: Lifecycle

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear
    
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurple
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        fetchFromDatabase()
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
    
    func fetchFromDatabase()
    {
        
        QnClient.sharedInstance.getFollowing { (users) in
            self.following = ConnectionsModel(connections: users)
            self.tableView.reloadData()
        }
    
    }

    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if following.numberOfConnectionSections() == 0 {
            let emptyView = EmptyView(frame: self.view.frame, image: #imageLiteral(resourceName: "connections_icon"), titleText: "No Connections", descriptionText: "When you follow a new connection you will see them here")
            
            self.tableView.backgroundView = emptyView
            
            return 0
        }else {
            
            self.tableView.backgroundView = nil
            return following.numberOfConnectionSections()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return following.numberOfConnectionsInSection(section)
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
//        
//        if profileImage != nil {
//            cell.profileImageView.image = profileImage
//        }else {
//            cell.profileImageView.image = ProfileImageCreator.create(connection.firstName, last: connection.lastName)
//        }
        
        if let connection = following.connectionAtIndexPath(indexPath) {
            let firstName = connection.firstName
            let lastName = connection.lastName
            
            cell.nameLabel.text = firstName! + " " + lastName!
            
            let profileImage = following.imageForConnectionAt(indexPath: indexPath)
            if profileImage != nil {
                cell.profileImageView.image = profileImage
            }else {
                cell.profileImageView.image = ProfileImageCreator.create(connection.firstName, last: connection.lastName)
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return following.titleForSection(section)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return following.indexTitle()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! ConnectionCell
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width) / 2
        cell.profileImageView.layer.borderWidth = kProfileBorderWidth
        cell.profileImageView.layer.borderColor = UIColor.qnPurple.cgColor
        
        cell.profileImageView.clipsToBounds = true
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if following.numberOfConnections() != 0 {
            if let user = following.connectionAtIndexPath(indexPath) {
    
                let profileNavController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewControllerOtherUserNav") as! UINavigationController
                let profileViewController = profileNavController.viewControllers.first as! ProfileViewControllerOtherUser
                profileViewController.configureViewController(user: user)
                present(profileNavController, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    func positionForBar(_ bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    
}

extension ConnectionsViewController: ImageDownloaderDelegate {
    
    func imageDownloaded(image: UIImage?) {
        self.tableView.reloadData()
    }
    
}

extension ConnectionsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let point = gestureRecognizer.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: point) else {
            return false
        }
        
        
        if following.numberOfConnections() != 0 {
            
            
            if following.numberOfConnections() != 0 {
                
                let connection = following.connectionAtIndexPath(indexPath)
                let name = (connection?.firstName)! + " " + (connection?.lastName)!
                let message = QnEncoder(user: connection!).encodeUserInfo()
                let qrImage = QNectCode(message: message).image
                
                let qnectAlertView = QNectAlertView()
                
                qnectAlertView.addButton("Delete Connection") {
                    
                    
                    let currentUser = FIRAuth.auth()!.currentUser!
                    
                    self.databaseRef.child("following").child(currentUser.uid).child(connection!.uid).removeValue()
                    
                    RKDropdownAlert.title("You have deleted \(connection!.firstName!) \(connection!.lastName!) as a connection", backgroundColor: UIColor.gray, textColor: UIColor.white)
                    
                }
                
                qnectAlertView.showTitle(name, subTitle: "\(connection!.username!)", duration: 0.0, completeText: nil, style: .contact, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF, contactImage: qrImage)
            }
        }
        
        return true
        
    }
    
}
