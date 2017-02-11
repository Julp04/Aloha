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

class ConnectionsViewController: UITableViewController, UIGestureRecognizerDelegate {

    
    var userAddedConnectionsModel:ConnectionsModel?
    var addedUserConnectionsModel:ConnectionsModel?
    let kCellHeight:CGFloat = 70.0
    let kProfileBorderWidth:CGFloat = 2.0
    let kPressDuration = 0.35
    var selectedConnection:User?
    
    var  segmentControl = UISegmentedControl(items: ["I added", "Added Me"])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        createTitleView()
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.qnPurpleColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.refreshControl?.addTarget(self, action: #selector(ConnectionsViewController.refresh), for: UIControlEvents.valueChanged)
        
        self.refreshControl?.tintColor = UIColor.qnPurpleColor()
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = kPressDuration
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)
        
        
        
        let ref = FIRDatabase.database().reference()
        
        let userAddedContactsRef = ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userAddedContacts")
        
        userAddedContactsRef.observe(.value, with: { (snapshot) in
            var addedUsers = [User]()
            
            
            
            for item in snapshot.children {
                let user = User(snapshot: item as! FIRDataSnapshot)
                addedUsers.append(user)
            }
            
            self.userAddedConnectionsModel = ConnectionsModel(connections: addedUsers)
            self.tableView.reloadData()
            
        })
        
        
        
        let contactsAddedUserRef = ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("contactsAddedUser")
        
        contactsAddedUserRef.observe(.value, with: { (snapshot) in
            var contactsAdded = [User]()
            
            for item in snapshot.children {
              
                let contact = User(snapshot: item as! FIRDataSnapshot)
                contactsAdded.append(contact)
                
            }
        
            self.addedUserConnectionsModel = ConnectionsModel(connections: contactsAdded)
            self.tableView.reloadData()
        })
    }

    func createTitleView()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 55))
        
        segmentControl.frame = CGRect(x: 0, y: 24, width: 200, height: 23)
        segmentControl.tintColor = UIColor.white
        segmentControl.addTarget(self, action: #selector(ConnectionsViewController.segmentControlSwitched(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        
        
        
        let label = UILabel(frame: CGRect(x: 66, y: 5, width: 100, height: 15))
        label.textColor = UIColor.white
        label.text = "QNections"
        
        
        
        view.addSubview(label)
        view.addSubview(segmentControl)
        self.navigationItem.titleView = view
    }
    
    func segmentControlSwitched(_ sender:UISegmentedControl)
    {
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
   
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if userAddedConnectionsModel == nil || userAddedConnectionsModel?.numberOfConnections() == 0{
                return 1
            }else {
                return userAddedConnectionsModel!.numberOfConnectionSections()
            }
        }else {
            if addedUserConnectionsModel == nil || addedUserConnectionsModel?.numberOfConnections() == 0 {
                return 1
            }else {
                return addedUserConnectionsModel!.numberOfConnectionSections()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if userAddedConnectionsModel == nil || userAddedConnectionsModel?.numberOfConnections() == 0{
                return 1
            }else {
                return userAddedConnectionsModel!.numberOfConnectionsInSection(section)
            }
        }else {
            if addedUserConnectionsModel == nil || addedUserConnectionsModel?.numberOfConnections() == 0 {
                return 1
            }else {
                return (addedUserConnectionsModel?.numberOfConnectionsInSection(section))!
            }
        }
    }
    
 

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell") as! ConnectionCell
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if userAddedConnectionsModel == nil || userAddedConnectionsModel?.numberOfConnections() == 0{
                cell.nameLabel.text = "No connections to display"
                cell.profileImageView.image = nil
            }else {
                
                let connection = userAddedConnectionsModel!.connectionAtIndexPath(indexPath)
                let firstName = connection.firstName
                let lastName = connection.lastName
                
                cell.nameLabel.text = firstName! + " " + lastName!
                cell.profileImageView.image = ProfileImage.createProfileImage(connection.firstName, last: connection.lastName)
                
                QnUtilitiy.getProfileImageForUser(user: connection, completion: { (image, error) in
                    if error != nil {
                        print(error!)
                    }else {
                        cell.profileImageView.image = image
                    }
                })
            }
        }else {
            if addedUserConnectionsModel == nil || addedUserConnectionsModel?.numberOfConnections() == 0{
                cell.nameLabel.text = "No connections to display"
                cell.profileImageView.image = nil
            }else {
                
                let connection = addedUserConnectionsModel!.connectionAtIndexPath(indexPath)
                let firstName = connection.firstName
                let lastName = connection.lastName
                
                cell.nameLabel.text = firstName! + " " + lastName!
                cell.profileImageView.image = ProfileImage.createProfileImage(connection.firstName, last: connection.lastName)
                
                QnUtilitiy.getProfileImageForUser(user: connection, completion: { (image, error) in
                    if error != nil {
                        print(error!)
                    }else {
                        cell.profileImageView.image = image
                    }
                })
                
            }
        }

        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if segmentControl.selectedSegmentIndex == 0 {
            return userAddedConnectionsModel?.titleForSection(section)
        }else {
            return addedUserConnectionsModel?.titleForSection(section)
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if segmentControl.selectedSegmentIndex == 0 {
            return userAddedConnectionsModel?.indexTitle()
        }else {
            return addedUserConnectionsModel?.indexTitle()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! ConnectionCell
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width) / 2
        cell.profileImageView.layer.borderWidth = kProfileBorderWidth
        cell.profileImageView.layer.borderColor = UIColor.qnPurpleColor().cgColor
        
        cell.profileImageView.clipsToBounds = true
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentControl.selectedSegmentIndex == 0 {
        
            if userAddedConnectionsModel?.numberOfConnections() != 0 {
                selectedConnection = userAddedConnectionsModel?.connectionAtIndexPath(indexPath)
                
                self.performSegue(withIdentifier: "ContactSegue", sender: self)
            }
        }else {
            if addedUserConnectionsModel?.numberOfConnections() != 0 {
                selectedConnection = addedUserConnectionsModel?.connectionAtIndexPath(indexPath)
                self.performSegue(withIdentifier: "ContactSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let contactVC = navVC.topViewController as? ContactViewController {
                contactVC.configureViewController(selectedConnection!)
            }
        }
    }
    
    
    
    func refresh()
    {
        
      
    }
    
    func reloadData()
    {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    //MARK: - Gesture Delegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        return true
     
    }
    
    //MARK: - Toolbar Delegate
    
    func positionForBar(_ bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }


}
